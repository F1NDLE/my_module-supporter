#!/system/bin/sh

MODDIR=${0%/*}
TARGET_DIR="/data/adb/tricky_store"
REPO_FILE="$MODDIR/system/etc/f1ndle/repository.txt"
LOG_FILE="$MODDIR/logs/action.log"

# Создаем директории
mkdir -p "$TARGET_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Функция логирования
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "Запуск F1NDLE Action через Magisk Manager"

# Функция загрузки файла с GitHub
download_from_github() {
    local file_name=$1
    local repo_url=$(cat "$REPO_FILE" 2>/dev/null | tr -d '\r\n')
    local url="${repo_url}${file_name}"
    local temp_file="/cache/${file_name}.tmp"
    
    log "Загрузка с GitHub: $url"
    
    # Пытаемся скачать с помощью wget
    if command -v wget >/dev/null 2>&1; then
        wget -O "$temp_file" "$url" >> "$LOG_FILE" 2>&1
    # Пытаемся скачать с помощью curl
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$temp_file" "$url" >> "$LOG_FILE" 2>&1
    else
        log "Ошибка: не найден wget или curl"
        return 1
    fi
    
    if [ $? -eq 0 ] && [ -s "$temp_file" ]; then
        mv -f "$temp_file" "$TARGET_DIR/$file_name"
        chmod 644 "$TARGET_DIR/$file_name"
        log "Успешно обновлен с GitHub: $file_name"
        return 0
    else
        log "Ошибка загрузки с GitHub: $file_name"
        rm -f "$temp_file"
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
    # Загружаем файлы с GitHub
    download_from_github "keybox.xml"
    download_from_github "target.txt"
    download_from_github "security_patch.txt"
    
    # Устанавливаем SELinux в enforcing режим
    setenforce 1 >/dev/null 2>&1
    log "SELinux установлен в: $(getenforce)"
    
    # Запускаем Play Integrity Fix
    run_pif
    
    log "Action завершен"
    echo "F1NDLE Action выполнено успешно! Файлы обновлены с GitHub."
}

# Запускаем основную функцию
main