{ config, pkgs }:

pkgs.writeShellScript "telegram-notify" ''
  # ZED chiama lo script come: telegram-notify destinatario < email_completa
  # Leggiamo l'intera mail dallo stdin
  EMAIL="$(cat)"

  # Estraiamo il Subject dagli header
  SUBJECT="$(echo "$EMAIL" | grep -m1 "^Subject:" | sed 's/Subject: //')"

  # Estraiamo il corpo (tutto dopo la riga vuota che separa headers e body)
  # Aggiungiamo un piccolo filtro sed per evitare che eventuali simboli "<" o ">" nei log rompano l'HTML
  BODY="$(echo "$EMAIL" | sed '1,/^$/d' | sed 's/</\&lt;/g; s/>/\&gt;/g')"

  CHAT_ID="$(cat ''${config.age.secrets.telegram_chat_id.path})"
  TOKEN="$(cat ''${config.age.secrets.telegram_token.path})"

  ${pkgs.curl}/bin/curl -s -X POST \
    "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d parse_mode="HTML" \
    --data-urlencode text="🖥️ <b>$SUBJECT</b>

<pre><code>$BODY</code></pre>"
''
