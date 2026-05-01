if [ "$(id -u)" = 0 ]; then
    console.red
    if [ $ARG_IGNORE_ROOT = 1 ]; then
        echo 'Скрипт запущен от имени root.'
        echo
        console.normal
    else
        cat <<EOF
Этот скрипт не требует root-прав для исполнения. Пожалуйста, не запускайте
всякие скрипты из интернета от имени root-пользователя.

Если у Вас нет выбора, запустите с флагом --ignore-root.
EOF
        console.normal
        exit 1
    fi
fi
