# =============================================================================
#
# In order for this extractor to run according to your preferences, 
# the following parameters need to be set. 
# 
# Some parameters can be left with the default values provided here - in that 
# case it is important to verify that the default value is appropriate to 
# your system. It is especially important to verify that paths to files and 
# software applications are valid in your system.
#
# =============================================================================

# name to show in rabbitmq queue list
extractorName = "terra.plantcv"

# URL to be used for connecting to rabbitmq
rabbitmqURL = "amqp://guest:guest@localhost/%2f"

# name of rabbitmq exchange
rabbitmqExchange = "clowder"

# type of files to process
messageType = "*.file.image.#"

# trust certificates, set this to false for self signed certificates
sslVerify=False

### plantcv settings: start
# plantcv script path
exRootPath = "/home/ubuntu/arpae/extractors-plantcv"
plantcvTool = exRootPath + "/bin/extract.sh"
plantcvOutputDir = "/home/ubuntu/plantcv-output"
### plantcv settings: end

