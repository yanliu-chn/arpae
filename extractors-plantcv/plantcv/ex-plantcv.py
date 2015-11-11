#!/usr/bin/env python

import logging
import os
import subprocess
import tempfile
import re
from config import *
import pyclowder.extractors as extractors
import pprint # debug

def main():
    global extractorName, messageType, rabbitmqExchange, rabbitmqURL, logger

    #set logging
    logging.basicConfig(format='%(asctime)-15s %(levelname)-7s : %(name)s - %(message)s', level=logging.INFO)
    logging.getLogger('pyclowder.extractors').setLevel(logging.DEBUG)
    logger = logging.getLogger(extractorName)
    logger.setLevel(logging.DEBUG)

    #connect to rabbitmq
    extractors.connect_message_bus(extractorName=extractorName,
                                   messageType=messageType,
                                   processFileFunction=process_file,
                                   rabbitmqExchange=rabbitmqExchange,
                                   rabbitmqURL=rabbitmqURL)

# ----------------------------------------------------------------------
# Process the file and upload the results
def process_file(parameters):
    global exRootPath, plantcvTool, plantcvOutputDir  
    logger = logging.getLogger(extractorName)
    str_params = pprint.pformat(parameters)
    logger.info("PARAMETERS: " + str_params) # debug
    print "PARAMETERS: " + str_params # debug

    infile = parameters['inputfile']
    filename = parameters['filename']
    fileid = parameters['fileid']
    logger.info("inputfile=%s filename=%s fileid=%s" % (infile, filename, fileid))

    try:
        # check if it is plantcv images
        #TODO: current way is limited. correct way is to check tags
        if re.match(r"^(VIS|NIR)_(SV|TV)(_\d+)*_z\d+_\d+\.jpg$", filename) is None :
            logger.info("image %s is not my business, skipping..." % (infile))
        else:
            #TODO: if infile not exist, download from REST API
            if not os.path.exists(infile) :
                logger.info("inputfile %s is remote, downloading..." % (infile))
                infile = download_file(parameters['channel'], parameters['header'], parameters['host'], parameters['secretKey'], parameters['fileid'], parameters['intermediatefileid'], parameters['ext'])
                logger.info("downloaded inputfile is %s." % (infile))

            # run command
            str_cmd = "EX-CMD: " + plantcvTool + " " +  infile + " " + filename + " " + fileid + " " + plantcvOutputDir 
            logger.info(str_cmd)
            print str_cmd # debug
            success = subprocess.call([plantcvTool, infile, filename, fileid, plantcvOutputDir], stderr=subprocess.STDOUT, shell=False)
            if (success != 0) :
                raise Exception("plantcv script %s failed"%(plantcvTool))

            # collect results
            listfile = plantcvOutputDir + "/" + fileid + "/.filelist"
            if os.path.exists(listfile) :
                with open(listfile) as file_outputlist:
                    fcontent = file_outputlist.read().splitlines()
                    # upload output files as preview
                    for ofile in fcontent :
                        if os.path.exists(ofile) :
                            extractors.upload_preview(previewfile=ofile, parameters=parameters)
                            #print "uploading " + ofile 
            # send metadata
            logfile = plantcvOutputDir + "/" + fileid + "/.log"
            with open(logfile) as file_log:
                fcontent = file_log.read()
                mdata = {}
                mdata['extractor_id'] = extractorName
                mdata['generated_from'] = extractors.get_file_URL(fileid, parameters)
                mdata['description'] = fcontent
                mdata['tags'] = ['plantcv', 'image analysis'] 
                extractors.upload_file_metadata(mdata=mdata, parameters=parameters)
                extractors.upload_file_tags(tags=mdata, parameters=parameters)
                #print "log: " + fcontent 

    except Exception :
        raise

if __name__ == "__main__":
    main()
    #parameters = {}
    #parameters['inputfile'] = '/home/ubuntu/yanliu/VIS_SV_180_z700_379476.jpg'
    #parameters['filename'] = 'VIS_SV_180_z700_379476.jpg'
    #parameters['fileid'] = 'plantcv001'
    #process_file(parameters)
