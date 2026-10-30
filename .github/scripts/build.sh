#!/usr/bin/env bash
# flutter build'i çalıştırır; başarısız olursa hatanın özetini GitHub
# açıklaması olarak yazar (log indirilemeyen yerlerden de okunabilsin diye).
set -o pipefail
flutter build "$@" 2>&1 | tee build.log
status=$?
if [ $status -ne 0 ]; then
  summary=$(grep -E -A6 "What went wrong|error:|Error:|Error \(Xcode\)|e: " build.log | head -60)
  # Eşleşme yoksa logun sonu (ör. Xcode'un kendi biçiminde bir hata).
  [ -z "$summary" ] && summary=$(tail -40 build.log)
  # Tek satıra (awk: macOS'taki BSD sed GNU sözdizimini bilmiyor).
  summary=$(printf '%s\n' "$summary" | awk 'BEGIN { ORS = "%0A" } { gsub(/%/, "%25"); gsub(/\r/, ""); print }')
  echo "::error title=flutter build $1 başarısız::${summary}"
fi
exit $status
