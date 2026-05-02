# $? != 0  =>  aborted
gpg_setup_guide() {
    echo "Сейчас я выполню команду:"
    console.blue
    echo "gpg --full-gen-key"
    console.normal
    cat <<EOF
Это создаст новый ключ шифрования. Выбирайте варианты по умолчанию, подтвердите,
что всё верно, а затем введите Ваши имя и адрес эл. почты (один из них, если у
Вас их несколько); комментарий можно оставить пустым. Затем мы продолжим.
EOF
    local ans="$(dialog_options "0=Стоп, я разберусь самостоятельно" \
        "1=Продолжить")"
    if [ $ans = 0 ]; then
        return 1
    fi
    if ! gpg --full-gen-key; then
        console.red
        echo "Программа завершилась с ошибкой. Прерываем установщик."
        console.normal
        exit 1
    fi
    return 0
}
