import os
import sys
import shutil

source_folder = sys.argv[1]
target_folder = sys.argv[2]
extension = sys.argv[3]

if (extension == "all"):
    if (os.path.exists(target_folder)):
        shutil.rmtree(target_folder)
    shutil.copytree(source_folder, target_folder)

else:
    files = os.listdir(source_folder)
    files_to_copy = []
    ext_length = len(extension) * -1

    for f in files:
        if (f[ext_length:].lower() == extension.lower()):
            files_to_copy.append(f)

    for f in files_to_copy:
        shutil.copy2(source_folder + '/' + f, target_folder + '/' + f)