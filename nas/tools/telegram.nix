{ config, ... }:

{
  age.secrets.telegram_token = {
    file = ../../secrets/telegram_token.age;
    owner = "root";
  };
  age.secrets.telegram_chat_id = {
    file = ../../secrets/telegram_chat_id.age;
    owner = "root";
  };
}
