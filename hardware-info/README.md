# Hardware info

Katalog na dane sprzętowe zebrane z różnych komputerów, żeby mieć do nich
dostęp z dowolnej maszyny przez git.

## Jak dodać dane ze swojego komputera (np. miniPC)

1. Sklonuj/zaktualizuj to repo na danym komputerze.
2. Uruchom skrypt zbierający dane:
   ```bash
   ./hardware-info/collect.sh
   ```
   Utworzy plik `hardware-info/<nazwa-hosta>.md` z informacjami o CPU, RAM,
   dyskach, sieci itd.
3. Zacommituj i wypchnij zmiany:
   ```bash
   git add hardware-info/<nazwa-hosta>.md
   git commit -m "Add hardware info for <nazwa-hosta>"
   git push
   ```

Po tym dane będą widoczne z każdego innego komputera po `git pull`.
