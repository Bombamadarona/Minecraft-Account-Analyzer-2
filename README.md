# 🔍 Minecraft Account Analyzer 2 (PowerShell)

Questo script PowerShell oltre ad analizzare i file `usernamecache.json` e `usercache.json` presenti nella cartella `.minecraft` controlla se gli accaunt sono SP oppure Premium.

Questo script è stato realizzato dal server discord SS LEARN IT (https://discord.gg/UET6TdxFUk).

## 🔍 Funzionalità

- Controlla se esiste la cartella `.minecraft` nel percorso predefinito `%appdata%`.
- Legge il contenuto di `usernamecache.json` (se esistente) ed estrae i nomi utente presenti.
- Legge il contenuto di `usercache.json` (se esistente) ed estrae i nomi utente registrati.
- Controlla se gli accaunt sono SP oppure Premium
- Mostra a schermo una lista di account trovati nei rispettivi file e mostra se un accaunt è SP oppure Premium
- Segnala con `[Errore]` gli accaunt non esistenti o non processati correttamente

# 📂 File/Database analizzati

- `usernamecache.json` – contiene la cronologia dei nomi utente utilizzati.
- `usercache.json` – contiene gli account associati a UUID e nomi.
- NickMC per trovare corrispondenze con gli accaunt
- API di minecraft per trovare corrispondenze con accaunt premium 

## ▶️ Utilizzo

1. Apri PowerShell (amministratore).
2. Copia e incolla lo script nel terminale oppure salvalo in un file, ad esempio `accaunt-analyzer-2.ps1`.
3. Esegui lo script:
`.\accaunt-analyzer-2.ps1`

Oppure puoi semplicemente eseguire lo script tramite un comando senza scaricare il file:

1. Apri PowerShell (amministratore).
2. `iex (iwr -useb "https://raw.githubusercontent.com/Bombamadarona/Minecraft-Account-Analyzer-2/refs/heads/main/accaunt-analyzer-2.ps1")`

## 📎 Note aggiuntive

- Lo script non modifica alcun file, esegue solo una lettura.

- Utile per effettuare controlli alts.
