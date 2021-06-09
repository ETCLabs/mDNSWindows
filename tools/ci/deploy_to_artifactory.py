"""Deploys binaries to a GitHub release given the specified tag name."""
import argparse
import os
import shutil
import zipfile

from artifactory import ArtifactoryPath

THIS_FILE_DIRECTORY = os.path.dirname(os.path.realpath(__file__))
ARTIFACTORY_BASE_URL = "https://etc.jfrog.io/artifactory/mdnswindows/"


def stage_binaries():
    """Gathers the x86 and x64 installation and the merge module to a common location to upload
    to GitHub"""

    os.makedirs("deploy", exist_ok=True)

    with zipfile.ZipFile(os.path.join("deploy", "mDNSWindows_x64.zip"), "w") as archive:
        for (dirpath, dirnames, filenames) in os.walk(os.path.join("build_x64", "install")):
            for file in filenames:
                relative_path_from_base = os.path.join(dirpath, file)
                # Add the file to the zip archive using the relative path from the directory
                # build_x64/install/
                archive.write(
                    relative_path_from_base,
                    relative_path_from_base[len(os.path.join("build_x64", "install", "")) :],
                )

    with zipfile.ZipFile(os.path.join("deploy", "mDNSWindows_x86.zip"), "w") as archive:
        for (dirpath, dirnames, filenames) in os.walk(os.path.join("build_x86", "install")):
            for file in filenames:
                relative_path_from_base = os.path.join(dirpath, file)
                archive.write(
                    relative_path_from_base,
                    relative_path_from_base[len(os.path.join("build_x86", "install", "")) :],
                )

    shutil.copy2(
        os.path.join("tools", "install", "bin", "Release", "ETC_mDNSInstall.msm"),
        os.path.join("deploy", "ETC_mDNSInstall.msm"),
    )


def deploy_binaries(version: str):
    """Deploys staged binaries to cloud Artifactory."""
    path = ArtifactoryPath(
        ARTIFACTORY_BASE_URL + f"/{version}", apikey=os.getenv("ETC_CLOUD_ARTIFACTORY_API_KEY")
    )
    path.mkdir()
    path.deploy_file(os.path.join("deploy", "mDNSWindows_x64.zip"))
    path.deploy_file(os.path.join("deploy", "mDNSWindows_x86.zip"))
    path.deploy_file(os.path.join("deploy", "ETC_mDNSInstall.msm"))


def main():
    parser = argparse.ArgumentParser(
        description="Deploy mDNSWindows artifacts to cloud Artifactory"
    )
    parser.add_argument("version", help="Artifact version being deployed")
    args = parser.parse_args()

    # Make sure our cwd is the root of the repository
    os.chdir(os.path.abspath(os.path.join(THIS_FILE_DIRECTORY, "..", "..")))

    stage_binaries()
    deploy_binaries(args.version)


if __name__ == "__main__":
    main()
