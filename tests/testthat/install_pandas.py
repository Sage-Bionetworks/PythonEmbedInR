import sys
import os
import errno
import pkg_resources
import glob
import shutil

import inspect
import subprocess


# pin the version that we use in this test
# e.g. 1.0.3 has issues installing from a wheel on Windows
# not related to PythonEmbedInR
# https://stackoverflow.com/q/60767017
PANDAS_VERSION="1.0.1"


def localSitePackageFolder(root):
    if os.name=='nt':
        # Windows
        return os.path.join(root, 'Lib', 'site-packages')
    # Mac, Linux
    return os.path.join(root, 'lib', "python{}.{}".format(sys.version_info.major, sys.version_info.minor), 'site-packages')

def addLocalSitePackageToPythonPath(root):
    # PYTHONPATH sets the search path for importing python modules
    sitePackages = localSitePackageFolder(root)

    os.environ['PYTHONPATH'] += sitePackages
    sys.path.append(sitePackages)

    inst_module_dir = os.path.join(root, 'python')
    os.environ['PYTHONPATH'] += inst_module_dir
    sys.path.append(inst_module_dir)

    # modules with .egg extensions (such as future and synapseClient) need to be explicitly added to the sys.path
    for eggpath in glob.glob(sitePackages+os.sep+'*.egg'):
        os.environ['PYTHONPATH'] += os.pathsep+eggpath
        sys.path.append(eggpath)


def main(command, path):
    """
    Install pandas or remove for testing.
    :param command: "install" or "uninstall"
    :param path: the path prefix of the directory to install pandas into
    """

    path = pkg_resources.normalize_path(path)
    moduleInstallationPrefix = os.path.join(path, 'inst')
    localSitePackages=localSitePackageFolder(moduleInstallationPrefix)

    addLocalSitePackageToPythonPath(moduleInstallationPrefix)
    from pip_install import install as pip_install, remove as pip_remove

    if not os.path.exists(localSitePackages):
        os.makedirs(localSitePackages)

    if command == 'install':
        pip_install('pandas=={}'.format(PANDAS_VERSION), localSitePackages)
    elif command == 'uninstall':
        pip_remove('pandas', localSitePackages)
    else:
        raise Exception("command not supported: " + command)

