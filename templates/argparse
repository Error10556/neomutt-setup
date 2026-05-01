ARG_IGNORE_ROOT=0

while [ "$#" != 0 ]; do
    if [ "$1" = "--ignore-root" ]; then
        ARG_IGNORE_ROOT=1
    else
        console.red
        printf \
$'Нераспознанный аргумент: "%s". Мы принимаем только --ignore-root.' "$1"
        console.normal
        exit 1
    fi
    shift
done
