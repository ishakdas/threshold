#!/usr/bin/env bash
# flutter build'i çalıştırır; başarısız olursa hatanın özetini GitHub
# açıklaması olarak yazar (log indirilemeyen yerlerden de okunabilsin diye).
set -o pipefail
flutter build "$@" 2>&1 | tee build.log
status=$?
if [ $status -ne 0 ]; then
  summary=$(grep -E -A6 "What went wrong|error:|Error:|e: " build.log | head -60 | sed ':a;N;$!ba;s/%/%25/g;s/\r//g;s/\n/%0A/g')
  echo "::error title=flutter build $1 başarısız::${summary}"
fi
exit $status
