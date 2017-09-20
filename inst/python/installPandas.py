import sys   
import pip
import os
import errno
import pkg_resources
import glob

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
    
def main(path):
    path = pkg_resources.normalize_path(path)
    moduleInstallationPrefix=path+os.sep+"inst"

    localSitePackages=localSitePackageFolder(moduleInstallationPrefix)
    
    addLocalSitePackageToPythonPath(moduleInstallationPrefix)

    if not os.path.exists(localSitePackages):
      os.makedirs(localSitePackages)
    
    call_pip('pandas', localSitePackages)

def call_pip(packageName, target):
        rc = pip.main(['install', packageName,  '--upgrade', '--quiet', '--target', target])
        if rc!=0:
            raise Exception('pip.main returned '+str(rc))
