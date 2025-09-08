
#!/system/bin/sh

MODDIR=${0%/*}
TARGET_DIR="/data/adb/tricky_store"
MODULE_SYSTEM_DIR="$MODDIR/system/etc/f1ndle"
LOG_FILE="$MODDIR/logs/service.log"

# Создаем директории
mkdir -p "$TARGET_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Функция логирования
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "Запуск F1NDLE Auto Update service"

# Копируем файлы из модуля в целевую директорию
copy_from_module() {
    local file_name=$1
    local default_file="$MODULE_SYSTEM_DIR/default.$file_name"
    local target_file="$TARGET_DIR/$file_name"
    
    if [ -f "$default_file" ]; then
        cp -f "$default_file" "$target_file"
        chmod 644 "$target_file"
        log "Скопирован из модуля: $file_name"
        return 0
    else
        log "Файл не найден в модуле: $file_name"
        return 1
    fi
}

# Запускаем Play Integrity Fix
run_pif() {
    log "Поиск Play Integrity Fix..."
    
    if [ -f "/data/adb/modules/playintegrityfix/autopif2.sh" ]; then
        log "Найден autopif2.sh, запускаю..."
        sh /data/adb/modules/playintegrityfix/autopif2.sh -a -p >> "$LOG_FILE" 2>&1
        log "autopif2.sh выполнен"
        return 0
    fi
    
    if [ -f "/data/adb/modules/playintegrityfix/action.sh" ]; then
        log "Найден action.sh, запускаю..."
        sh /data/adb/modules/playintegrityfix/action.sh -a -p >> "$LOG_FILE" 2>&1
        log "action.sh выполнен"
        return 0
    fi
    
    log "Play Integrity Fix не найден"
    return 1
}

# Основная функция
main() {
    # Копируем файлы из модуля
    copy_from_module "keybox.xml"
    copy_from_module "target.txt"
    copy_from_module "security_patch.txt"
    
    # Устанавливаем SELinux в enforcing режим
    setenforce 1 >/dev/null 2>&1
    log "SELinux установлен в: $(getenforce)"
    
    # Запускаем Play Integrity Fix
    run_pif
    
    log "Сервис завершил работу"
}

# Запускаем основную функцию
main