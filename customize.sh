#!/system/bin/sh

chmod 775 /data/adb/modules/F1NDLE_STRONG/customize.sh

chmod 775 /data/adb/modules/F1NDLE_STRONG/action.sh

chmod 775 /data/adb/modules/F1NDLE_STRONG/service.sh

MODDIR=${0%/*}
TARGET_DIR="/data/adb/tricky_store"
MODULE_SYSTEM_DIR="$MODDIR/system/etc/f1ndle"

# Создаем целевые директории
mkdir -p "$TARGET_DIR"
mkdir -p "$MODDIR/logs"

# Устанавливаем права на скрипты
chmod 755 "$MODDIR/service.sh"
chmod 755 "$MODDIR/action.sh"

# Копируем файлы по умолчанию из модуля
copy_if_missing() {
    if [ ! -f "$TARGET_DIR/$1" ] && [ -f "$MODULE_SYSTEM_DIR/default.$1" ]; then
        cp "$MODULE_SYSTEM_DIR/default.$1" "$TARGET_DIR/$1"
        chmod 644 "$TARGET_DIR/$1"
    fi
}

copy_if_missing "keybox.xml"
copy_if_missing "target.txt"
copy_if_missing "security_patch.txt"

# Создаем файл с URL репозитория, если его нет
if [ ! -f "$MODULE_SYSTEM_DIR/repository.txt" ]; then
    echo "https://raw.githubusercontent.com/F1NDLE/my_module-supporter/main/module_folder/" > "$MODULE_SYSTEM_DIR/repository.txt"
    chmod 644 "$MODULE_SYSTEM_DIR/repository.txt"
fi

# Создаем лог-файл установки
echo "Модуль установлен: $(date)" > "$MODDIR/logs/install.log"