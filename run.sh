oldDir=/Users/liang/Desktop/Liang/GitHub
newDir=/Users/liang/Desktop/OldTools
function work() {
    # echo  "$(pwd)/${1}";
    # echo $oldDir/$1
    cp -R $oldDir/$1 $newDir
    rm -rf $1/.git
    # rm -rf $1/$1.xcworkspace
    rm -rf $1/Example/Podfile.lock
    rm -rf $1/Example/Pods
    git checkout --orphan $1
    git add ./$1
    git commit -m "$1-init"
    git push origin $1 --progress
}

for file in $(ls $oldDir); do
    work $file
done
