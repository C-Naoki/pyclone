pyclone() {
    git_flag=0
    default_dir_name=${DEFAULT_VENV:-"test"}
    default_publish="no"

    if [ -z "${PYCLONE_PATH}" ]; then
        echo "Error: PYCLONE_PATH is not defined. Please define PYCLONE_PATH."
        return 1
    fi

    clone_path=${PYCLONE_PATH}
    clone_git_path=${clone_path}/git/

    while getopts "g" opt; do
        case $opt in
            g)
                git_flag=1
                ;;
            \?)
                echo "Invalid option: -$OPTARG"
                return 1
                ;;
        esac
    done
    shift $((OPTIND -1))

    echo -n "What is the virtual environment name? [$default_dir_name]: "
    read dir_name
    dir_name=${dir_name:-$default_dir_name}

    if [ -d "${clone_path}/${dir_name}" ] || [ -d "${clone_git_path}/${dir_name}" ]; then
        default_overwrite="no"
        while : ; do
            echo -n "The directory ${dir_name} already exists. Overwrite? (yes/no) [$default_overwrite]: "
            read overwrite
            overwrite=${overwrite:-$default_overwrite}
            if [[ "$overwrite" == "yes" ]] || [[ "$overwrite" == "no" ]]; then
                break
            else
                echo "Please enter either 'yes' or 'no'."
            fi
        done
        if [[ "$overwrite" == "no" ]]; then
            echo "Operation cancelled by user."
            return 1
        fi
    fi

    if [ $git_flag -eq 1 ]; then
        while : ; do
            echo -n "Do you publish the repository? (yes/no) [$default_publish]: "
            read publish
            publish=${publish:-$default_publish}
            if [[ "$publish" == "yes" ]] || [[ "$publish" == "no" ]]; then
                break
            else
                echo "Please enter either 'yes' or 'no'."
            fi
        done
    fi

    if [ $git_flag -eq 1 ]; then
        cd $clone_git_path
    else
        cd $clone_path
    fi

    git clone https://github.com/C-Naoki/my-python-templete.git $dir_name
    cd $dir_name
    sed -i "" "s/my-python-templete/$dir_name/g" pyproject.toml
    rm -rf .git

    make install
    git init

    echo "# $dir_name" > README.md

    if [ $git_flag -eq 1 ]; then
        repo_check_file="repo_check_$$.txt"
        python -c "
import pkg_resources
import time
try:
    pkg_resources.get_distribution('PyGithub')
except pkg_resources.DistributionNotFound:
    import subprocess
    subprocess.run(['pip', 'install', 'PyGithub'])
finally:
    import os
    from github import Github
    g = Github(os.getenv('GITHUB_TOKEN'))
    username = g.get_user().login
    try:
        g.get_user().get_repo('$dir_name')
        print('The repository $dir_name already exists on GitHub.')
    except:
        pass
    " > $repo_check_file
        if grep -q "The repository $dir_name already exists on GitHub." $repo_check_file; then
            echo "The repository $dir_name already exists on GitHub."
            rm $repo_check_file
            return 1
        fi
        rm $repo_check_file

        username=$(python -c "
import os
import time
from github import Github
g = Github(os.getenv('GITHUB_TOKEN'))
username = g.get_user().login
repo = g.get_user().create_repo('$dir_name', private=('$publish' == 'no'))
while repo.clone_url is None:
    time.sleep(0.5)
    repo = g.get_repo(f'{username}/{dir_name}')
print(username)")

        url="https://github.com/${username}/${dir_name}.git"
        git remote add origin $url
        git add .
        git commit -m ":tada: initial commit"
        git push -u origin master
    fi
}
