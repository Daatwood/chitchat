Chitchat::HaveWeMet - Tracks players(note & rating)

Chitchat - Records and manages messages from players.

Chitchat Goal:
* Compile Detailed Contacts
* Record whispers from players.

```
Chitchat.GetPlayerId[]
Chitchat.CreateDetail[string:player_id, string:owner]
Chitchat.GetDetail[string:player_id, boolean:is_battlenet] -- Returns Detail information about player_name
Chitchat.GetMessages[string:player_id, int:count] -- Returns
```



WhisperLog, KEY = tag
String tag - unique link to a player
Boolean unread - determines if there are new enties
Integer[] whispers - an array of WhisperEntry ids

MessageEntry, KEY = id
String sender - player sent message
String message - contents of the whisper
String timestamp - time and date of the message
Boolean incoming - determines if the message was sent or received
Integer id - WhisperEntry unique id

PlayerNote, KEY = tag
String tag - unique link to a player
String note - User added notes of a player.
Integer rating - User added rating
String class - User added player class
Integer roles - User added roles(Healer,Dps,Tank)7-THD, 6-TH, 5-TD, 4-T, 3-HD, 2-H, 1-D

-- Virtual Table, Generated in Chitchat
Tags
Key[String Tag] - unique link to a player
Value{WHISPER_LOG: whisper_log_id, PLAYER_NOTE: player_note_id} - a table with first value linking to whisperlog and second linking to playerNote


WhispersLog can be set to not be persistent and only exists in sessions.
WhisperEntry can be auto removed after X Days or Weeks.
PlayerNote can be set to not be auto generated
