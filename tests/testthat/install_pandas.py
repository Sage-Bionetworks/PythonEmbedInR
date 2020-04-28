import sys
import os
import errno
import pkg_resources
import glob
import shutil

# pin the version that we use in this test
# e.g. 1.0.3 has issues installing from a wheel on Windows
# not related to PythonEmbedInR
# https://stackoverflow.com/q/60767017
PANDAS_VERSION="1.0.1"

# pip main is not a public interface and is not programatically accessible
# in a stable way across python versions. the typical approach is to
# call pip in a subprocess using sys.executable, but running inside
# PythonEmbedInR sys.executable may not be what we want.
try:
    from pip import main as pipmain
except ImportError:
    from pip._internal import main as pipmain

def localSitePackageFolder(root):
    if os.name=='nt':
        # Windows
        return root+os.sep+"Lib"+os.sep+"site-packages"
    else:
        # Mac, Linux
        return root+os.sep+"lib"+os.sep+"python3.5"+os.sep+"site-packages"
    
def addLocalSitePackageToPythonPath(root):
    # PYTHONPATH sets the search path for importing python modules
    sitePackages = localSitePackageFolder(root)
    os.environ['PYTHONPATH'] = sitePackages
    sys.path.append(sitePackages)
    # modules with .egg extensions (such as future and synapseClient) need to be explicitly added to the sys.path
    for eggpath in glob.glob(sitePackages+os.sep+'*.egg'):
        os.environ['PYTHONPATH'] += os.pathsep+eggpath
        sys.path.append(eggpath)
    
def main(command, path):
    path = pkg_resources.normalize_path(path)
    moduleInstallationPrefix=path+os.sep+"inst"

    localSitePackages=localSitePackageFolder(moduleInstallationPrefix)
    
    addLocalSitePackageToPythonPath(moduleInstallationPrefix)

    if not os.path.exists(localSitePackages):
      os.makedirs(localSitePackages)

    if command == 'install':
      call_pip('pandas', localSitePackages, PANDAS_VERSION)
    elif command == 'uninstall':
      remove_dirs('pandas', localSitePackages)
    else:
      raise Exception("command not supported: "+command)

def call_pip(packageName, target, packageVersion=None):
    package = packageName if not packageVersion else "{}=={}".format(packageName, packageVersion)
    rc = pipmain(["install", package, '--upgrade', '--quiet', '--target', target])
    if rc!=0:
      raise Exception('pip.main returned '+str(rc))

def remove_dirs(prefix, baseDir):
    to_remove = glob.iglob(os.path.join(baseDir, prefix+"*"))
    for path in to_remove:
      if os.path.isdir(path):
        shutil.rmtree(path)
