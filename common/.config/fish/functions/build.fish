function build
    if test -x ./build.sh
        ./build.sh $argv
    else if test -x ./build
        ./build $argv
    else
        echo "No hay ./build.sh ni ./build ejecutable en $PWD" >&2
        return 1
    end
end
