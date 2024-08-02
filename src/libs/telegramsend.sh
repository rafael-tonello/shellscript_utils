#!/bin/bot

#A class with simple function to send messages and files to Telegram
#
#   example:
#       new "telegramsend" "telegram" "$ENV_BOTKEY" "$ENV_CHATID"
#       telegram->sendTextMessage "Hello World"
#       telegram->sendFile "/path/to/file
#


#init the class
#agrument botkey: the key of the bot
#argument chatId: the chat id to send the messages
this->init(){ local botkey="$1"; local chatId="$2"; local _prefix_="$3";
    this->botkey=$botkey
    this->chatId=$chatId
    this->prefix=$_prefix_
}

this->sendTextMessage(){ local message=$1
    curl -sS -X POST -H "Content-Type: application/json" -d "{\"chat_id\":\"$this->chatId\", \"text\":\"$this->prefix""$message\"}" https://api.telegram.org/bot$this->botkey/sendMessage > /dev/null
}

this->sendErrorMessage(){ local _error=$1
    this->sendTextMessage "📛Error📛\n $_error"
}

this->sendInfoMessage(){ local _info=$1
    this->sendTextMessage "🔷 Information 🔷 \n$_info"
}

this->sendWarningMessage(){ local _warning=$1
    this->sendTextMessage "🔶⚠ Warning ⚠🔶\n $_warning\n🔶⚠⚠🔶"
}

this->sendSuccessMessage(){ local _success=$1
    this->sendTextMessage "✅ Success ✅\n $_success"
}

this->sendFailureMessage(){ local _error=$1
    this->sendTextMessage "🆘 failure 🆘\n $_error\n🆘📛📛🆘"
}

this->sendFile(){ local file=$1
    curl -sS -X POST https://api.telegram.org/bot$this->botkey/sendDocument -F chat_id=$this->chatId -F document=@"$file"
}
