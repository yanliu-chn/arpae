# Clowder Image Preview Extractor

This uses ImageMagick, this exists on Linux as part of most distributions,
for example on Ubuntu you can use: `apt-get install imagemagick` to install
it. See also http://www.imagemagick.org/script/binary-releases.php#macosx.

Along with ImageMagick, ufraw-batch package should also be installed for converting RAW image formats. See http://ufraw.sourceforge.net/Install.html for general instructions.
On Ubuntu, you can use the command: `apt-get install ufraw-batch`. Homebrew formula for ufraw-batch is avaialable for Mac. See http://brewformulas.org/Ufraw.

To install and run the python extractor do the following:

1. Setup a [virtualenv](https://virtualenv.pypa.io)
   `virtualenv image`
2. Activate image virtualenv
   `source image/bin/activate`
2. Install required python packages using *pip*
   `pip install -r requirements.txt`
3. Install pyclowder
   `pip install git+https://opensource.ncsa.illinois.edu/stash/scm/cats/pyclowder.git`
   or if you have pyclowder checked out as well (useful when developing)
   ln -s ../../pyClowder/pyclowder pyclowder
4. Modify config.py
5. Start extractor `python ncsa.image.preview.py`
