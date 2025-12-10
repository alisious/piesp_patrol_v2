# Instrukcja obsługi aplikacji PIESP Patrol

## 1. Strona logowania

### Opis ekranu
Strona logowania jest pierwszym ekranem widocznym po uruchomieniu aplikacji. Wyświetla logo PIESP oraz formularz logowania.

![Strona logowania - widok ogólny](images/login_page_1.png)

![Strona logowania - formularz](images/login_page_2.png)

### Pola wprowadzania danych

#### Numer odznaki
- **Lokalizacja**: Pierwsze pole formularza, z ikoną odznaki po lewej stronie
- **Typ klawiatury**: Klawiatura numeryczna
- **Ograniczenia**: 
  - Akceptuje tylko cyfry (0-9)
  - Pole jest wymagane
- **Akcja klawiatury**: Po wprowadzeniu danych i naciśnięciu "Dalej" (Next), kursor automatycznie przechodzi do pola PIN
- **Walidacja**: Jeśli pole jest puste, wyświetlany jest komunikat błędu: "Podaj numer odznaki"

#### PIN
- **Lokalizacja**: Drugie pole formularza, z ikoną kłódki po lewej stronie
- **Typ klawiatury**: Klawiatura numeryczna
- **Ograniczenia**:
  - Akceptuje tylko cyfry (0-9)
  - Maksymalna długość: 6 cyfr
  - Wprowadzane znaki są ukryte (obscureText)
- **Akcja klawiatury**: Po wprowadzeniu danych i naciśnięciu "Dalej" (Next), można nacisnąć przycisk "Zaloguj"
- **Walidacja**: Jeśli pole jest puste, wyświetlany jest komunikat błędu: "Podaj PIN"

### Przyciski i akcje

#### Przycisk "Zaloguj"
- **Lokalizacja**: Główny przycisk pod polami formularza
- **Wygląd**: 
  - W stanie normalnym: przycisk z ikoną logowania i tekstem "Zaloguj"
  - Podczas logowania: przycisk z animowanym wskaźnikiem ładowania i tekstem "Logowanie…"
- **Funkcjonalność**: 
  - Wykonuje walidację wszystkich pól formularza
  - Jeśli walidacja się powiedzie, próbuje zalogować użytkownika
  - Podczas logowania przycisk jest nieaktywny (disabled)
  - Po pomyślnym zalogowaniu użytkownik jest przekierowywany do strony głównej aplikacji
- **Obsługa błędów**: W przypadku błędu logowania, komunikat błędu wyświetlany jest nad przyciskiem w kolorze czerwonym

#### Przycisk "Reset PIN"
- **Lokalizacja**: Tekstowy przycisk w prawym dolnym rogu formularza, pod informacją o adresie API
- **Funkcjonalność**: Przekierowuje do strony resetu PIN

#### Przycisk "Ustawienia" (ikona koła zębatego)
- **Lokalizacja**: W prawym górnym rogu ekranu, na pasku aplikacji (AppBar)
- **Funkcjonalność**: Otwiera stronę ustawień aplikacji

### Informacje dodatkowe
- **Adres API**: Pod przyciskiem "Zaloguj" wyświetlany jest aktualny adres API w formacie: "API: [adres]"
- **Komunikaty błędów**: Wszystkie błędy wyświetlane są w kolorze czerwonym nad przyciskiem "Zaloguj"

---

## 2. Strona ustawień

### Opis ekranu
Strona ustawień pozwala na konfigurację połączenia z serwerem API oraz zaawansowanych ustawień bezpieczeństwa TLS/CA.

![Strona ustawień - widok podstawowy](images/settings_page_1.png)

![Strona ustawień - sekcja zaawansowana](images/settings_page_2.png)

**Uwaga dla środowiska produkcyjnego:**
- **Base URL**: `http://portal.kacper.zw.int:3443`
- **Tryb TLS**: `systemThenAssetFallback`

### Pola wprowadzania danych

#### Base URL
- **Lokalizacja**: Pierwsze pole na stronie, z ikoną HTTP po lewej stronie
- **Typ klawiatury**: Klawiatura tekstowa z możliwością wprowadzania adresów URL
- **Opis**: Adres bazowy serwera API
- **Przykład**: `https://portal.kacper.zw.int:3443`
- **Pole wymagane**: Tak

#### Sekcja "Zaawansowane (TLS / CA)"
- **Lokalizacja**: Rozwijana sekcja (ExpansionTile) z ikoną ustawień
- **Funkcjonalność**: Po kliknięciu rozwija się, pokazując dodatkowe pola konfiguracyjne

##### Tryb TLS
- **Typ**: Lista rozwijana (Dropdown)
- **Dostępne opcje**:
  1. **systemOnly** - Używa tylko certyfikatów systemowych (MDM + network_security_config)
  2. **assetCa** - Używa certyfikatu PEM z folderu assets aplikacji
  3. **pinned** - Używa SPKI pinning (przypinanie kluczy publicznych)
  4. **systemThenAssetFallback** - Najpierw próbuje systemowych certyfikatów, potem z assets
- **Funkcjonalność**: Wybór trybu wpływa na widoczność innych pól w sekcji

##### Ścieżka PEM (asset)
- **Widoczność**: Wyświetlane tylko gdy wybrano tryb `assetCa` lub `systemThenAssetFallback`
- **Lokalizacja**: Pole tekstowe z ikoną dokumentu po lewej stronie
- **Opis**: Ścieżka do pliku certyfikatu PEM w folderze assets aplikacji
- **Przykład**: `assets/certs/kacper_ca.pem`
- **Typ klawiatury**: Klawiatura tekstowa

##### Dozwolone hosty
- **Lokalizacja**: Pole tekstowe z ikoną DNS po lewej stronie
- **Opis**: Lista dozwolonych hostów rozdzielonych przecinkami
- **Przykład**: `api.kacper.zw.int, portal.kacper.zw.int`
- **Typ klawiatury**: Klawiatura tekstowa
- **Format**: Wartości oddzielone przecinkami, białe znaki są automatycznie usuwane

##### Piny (SPKI/sha256)
- **Lokalizacja**: Pole tekstowe z ikoną odcisku palca po lewej stronie
- **Opis**: Lista pinów SPKI (SHA256) rozdzielonych przecinkami
- **Format**: Wartości w formacie hex lub Base64 SPKI, oddzielone przecinkami
- **Typ klawiatury**: Klawiatura tekstowa

### Przyciski i akcje

#### Przycisk "Zapisz"
- **Lokalizacja**: Główny przycisk pod wszystkimi polami, z ikoną zapisu
- **Funkcjonalność**:
  - Zapisuje wszystkie wprowadzone ustawienia
  - Zmiany są aktywne natychmiast po zapisaniu
  - Po zapisaniu wyświetlany jest zielony komunikat: "Zapisano. Zmiany działają od razu."

### Informacje dodatkowe

#### Informacje o wersji aplikacji
- **Lokalizacja**: Na dole strony, pod linią oddzielającą
- **Wyświetlane informacje**:
  - Numer wersji aplikacji
  - Numer buildu (jeśli dostępny)
  - Format: `[wersja] (build [numer])` lub tylko `[wersja]`
- **Status**: Podczas ładowania wyświetlany jest tekst: "Ładowanie informacji o wersji..."

---

## 3. Strona resetu PIN

### Opis ekranu
Strona resetu PIN pozwala na zmianę PIN-u użytkownika przy użyciu kodu bezpieczeństwa wygenerowanego przez supervisora.

![Strona resetu PIN](images/reset_pin_page.png)

### Pola wprowadzania danych

#### Numer odznaki
- **Lokalizacja**: Pierwsze pole formularza, z ikoną odznaki po lewej stronie
- **Typ klawiatury**: Klawiatura numeryczna
- **Ograniczenia**:
  - Akceptuje tylko cyfry (0-9)
  - Maksymalna długość: 4 cyfry
  - Minimalna długość: 4 cyfry
- **Akcja klawiatury**: Po wprowadzeniu danych i naciśnięciu "Dalej" (Next), kursor automatycznie przechodzi do pola "Nowy PIN"
- **Walidacja**: 
  - Jeśli pole jest puste: "Podaj numer odznaki"
  - Jeśli ma mniej niż 4 cyfry: "Numer odznaki musi mieć co najmniej 4 cyfry"

#### Nowy PIN
- **Lokalizacja**: Drugie pole formularza, z ikoną kłódki po lewej stronie
- **Typ klawiatury**: Klawiatura numeryczna
- **Ograniczenia**:
  - Akceptuje tylko cyfry (0-9)
  - Maksymalna długość: 6 cyfr
  - Minimalna długość: 4 cyfry
  - Wprowadzane znaki są ukryte (obscureText)
- **Akcja klawiatury**: Po wprowadzeniu danych i naciśnięciu "Dalej" (Next), kursor automatycznie przechodzi do pola "Potwierdź PIN"
- **Walidacja**: 
  - Jeśli pole jest puste: "Podaj PIN"
  - Jeśli ma mniej niż 4 cyfry: "PIN musi mieć co najmniej 4 cyfry"

#### Potwierdź PIN
- **Lokalizacja**: Trzecie pole formularza, z ikoną kłódki po lewej stronie
- **Typ klawiatury**: Klawiatura numeryczna
- **Ograniczenia**:
  - Akceptuje tylko cyfry (0-9)
  - Maksymalna długość: 6 cyfr
  - Wprowadzane znaki są ukryte (obscureText)
- **Akcja klawiatury**: Po wprowadzeniu danych i naciśnięciu "Dalej" (Next), kursor automatycznie przechodzi do pola "Kod bezpieczeństwa"
- **Walidacja**: 
  - Jeśli pole jest puste: "Potwierdź PIN"
  - Jeśli wartość nie zgadza się z "Nowy PIN": "PINy nie są zgodne"

#### Kod bezpieczeństwa
- **Lokalizacja**: Czwarte pole formularza, z ikoną bezpieczeństwa po lewej stronie
- **Typ klawiatury**: Klawiatura tekstowa
- **Ograniczenia**: Pole jest wymagane
- **Akcja klawiatury**: Po wprowadzeniu danych i naciśnięciu "Gotowe" (Done), można nacisnąć przycisk "Zatwierdź"
- **Walidacja**: Jeśli pole jest puste, wyświetlany jest komunikat błędu: "Podaj kod bezpieczeństwa"
- **Uwaga**: Kod bezpieczeństwa musi być wygenerowany przez supervisora w aplikacji

### Przyciski i akcje

#### Przycisk "Zatwierdź"
- **Lokalizacja**: Główny przycisk pod wszystkimi polami formularza
- **Wygląd**: 
  - W stanie normalnym: przycisk z ikoną zaznaczenia i tekstem "Zatwierdź"
  - Podczas przetwarzania: przycisk z animowanym wskaźnikiem ładowania i tekstem "Przetwarzanie…"
- **Funkcjonalność**: 
  - Wykonuje walidację wszystkich pól formularza
  - Sprawdza, czy "Nowy PIN" i "Potwierdź PIN" są identyczne
  - Jeśli walidacja się powiedzie, wysyła żądanie resetu PIN do serwera
  - Podczas przetwarzania przycisk jest nieaktywny (disabled)
  - Po pomyślnym zresetowaniu PIN-u:
    - Użytkownik jest przekierowywany z powrotem do poprzedniej strony
    - Wyświetlany jest komunikat sukcesu: "PIN został zresetowany"
- **Obsługa błędów**: W przypadku błędu, komunikat błędu wyświetlany jest nad przyciskiem w kolorze czerwonym

### Informacje dodatkowe
- **Komunikaty błędów**: Wszystkie błędy wyświetlane są w kolorze czerwonym nad przyciskiem "Zatwierdź"
- **Komunikaty sukcesu**: Po pomyślnym zresetowaniu PIN-u wyświetlany jest zielony komunikat na dole ekranu (SnackBar)

---

## 4. Zakładka Służba

### Opis ekranu
Zakładka "Służba" jest pierwszą zakładką w aplikacji (ikona tarczy z księżycem). Umożliwia rozpoczęcie i zakończenie służby patrolowej.

![Zakładka Służba - bez aktywnej służby](images/duty_tab.png)

### Wskaźnik aktywnej służby
- **Lokalizacja**: W prawym górnym rogu ekranu, obok nazwy użytkownika
- **Wygląd**: Ikona tarczy (shield) wyświetlana tylko gdy użytkownik ma aktywną służbę
- **Funkcjonalność**: Wizualny wskaźnik, że użytkownik jest obecnie na służbie

![Zakładka Służba - z aktywną służbą](images/duty_tab_with_shield.png)

### Przyciski i akcje

#### Przycisk "Rozpocznij służbę"
- **Lokalizacja**: Pierwszy przycisk w sekcji "Służba"
- **Wygląd**: Przycisk strzałkowy z tekstem "Rozpocznij służbę"
- **Stan aktywności**: 
  - Aktywny tylko gdy użytkownik **nie ma** aktywnej służby
  - Nieaktywny (szary) gdy użytkownik ma już rozpoczętą służbę
- **Funkcjonalność**: 
  - Pobiera listę zaplanowanych służb użytkownika z serwera
  - Jeśli pobranie się powiedzie, otwiera stronę wyboru służby (`my_duties_result_page`)
  - Jeśli nie ma zaplanowanych służb lub wystąpi błąd, wyświetla komunikat na dole ekranu (SnackBar)
- **Obsługa błędów**: 
  - W przypadku błędu sieciowego lub braku służb, wyświetlany jest komunikat w SnackBar
  - Przykładowe komunikaty: "Nie udało się pobrać służb." lub "Błąd podczas pobierania służb: [szczegóły]"

![Komunikat - brak służb](images/duty_tab_no_duties_snackbar.png)

#### Przycisk "Zakończ służbę"
- **Lokalizacja**: Drugi przycisk w sekcji "Służba"
- **Wygląd**: Przycisk strzałkowy z tekstem "Zakończ służbę"
- **Stan aktywności**: 
  - Aktywny tylko gdy użytkownik **ma** aktywną służbę
  - Nieaktywny (szary) gdy użytkownik nie ma rozpoczętej służby
- **Funkcjonalność**: Otwiera stronę szczegółów aktywnej służby (`current_duty_page`), gdzie można zakończyć służbę

### Strona wyboru służby (My Duties Result Page)

Po kliknięciu "Rozpocznij służbę" i pomyślnym pobraniu służb, użytkownik zostaje przekierowany do strony wyboru służby.

![Strona wyboru służby](images/my_duties_result_page.png)

- **Funkcjonalność**: Wyświetla listę dostępnych zaplanowanych służb
- **Akcja**: Użytkownik wybiera służbę z listy, aby ją rozpocząć

### Strona aktywnej służby (Current Duty Page)

Strona szczegółów aktywnej służby wyświetla informacje o rozpoczętej służbie i umożliwia jej zakończenie.

![Strona aktywnej służby](images/current_duty_page.png)

#### Informacje wyświetlane

**Karta służby zawiera:**

1. **Nagłówek:**
   - Typ służby (np. "Służba")
   - Nazwa jednostki (jeśli dostępna)

2. **Sekcja "Plan":**
   - **Start**: Planowana data i godzina rozpoczęcia służby
   - **Koniec**: Planowana data i godzina zakończenia służby

3. **Sekcja "Realizacja":**
   - **Lokalizacja startu**: Współrzędne geograficzne (szerokość i długość geograficzna) miejsca rozpoczęcia służby
   - **Start**: Rzeczywista data i godzina rozpoczęcia służby (z sekundami)
   - **Status**: Aktualny status służby

#### Formularz zakończenia służby

**Pole "Zakończenie":**
- **Lokalizacja**: Pole tekstowe na dole karty służby
- **Format**: `rrrr-MM-dd HH:mm` (np. `2024-11-23 14:30`)
- **Przycisk "Teraz"**: 
  - Ikona zegara po prawej stronie pola
  - Automatycznie wstawia aktualną datę i godzinę
  - Tooltip: "Teraz"
- **Walidacja**: 
  - Pole jest wymagane
  - Format daty musi być poprawny
  - Jeśli pole jest puste: "Uzupełnij datę zakończenia."
  - Jeśli format jest niepoprawny: "Niepoprawny format daty."

**Przycisk "Zakończ":**
- **Lokalizacja**: Pod polem "Zakończenie"
- **Wygląd**: 
  - W stanie normalnym: przycisk z tekstem "Zakończ"
  - Podczas pobierania lokalizacji: "Pobieranie lokalizacji..."
  - Podczas przetwarzania: przycisk nieaktywny
- **Funkcjonalność**: 
  1. Pobiera aktualną lokalizację GPS użytkownika
  2. Jeśli pobranie lokalizacji się nie powiedzie:
     - Wyświetla dialog z opcjami:
       - "Anuluj" - anuluje zakończenie służby
       - "Otwórz ustawienia aplikacji" / "Włącz GPS" - otwiera odpowiednie ustawienia (jeśli dotyczy)
       - "Kontynuuj bez lokalizacji" - pozwala zakończyć służbę bez lokalizacji
  3. Wysyła żądanie zakończenia służby do serwera z:
     - Datą i godziną zakończenia
     - Współrzędnymi geograficznymi (jeśli dostępne)
  4. Po pomyślnym zakończeniu:
     - Wyświetla komunikat sukcesu w SnackBar z informacją o typie służby i lokalizacji
     - Zamyka stronę i wraca do zakładki "Służba"
     - Aktualizuje stan aplikacji (usuwa aktywną służbę)

**Obsługa błędów:**
- Błędy lokalizacji: Dialog z opcjami kontynuacji
- Błędy serwera: Komunikat w SnackBar z szczegółami błędu
- Błędy walidacji: Komunikat pod przyciskiem "Zakończ" w kolorze czerwonym

![Komunikat po zakończeniu służby](images/duty_tab_stop_duty_snackbar.png)

### Informacje dodatkowe

- **Automatyczna aktualizacja**: Zakładka "Służba" automatycznie aktualizuje się po rozpoczęciu lub zakończeniu służby (przyciski zmieniają stan aktywności)
- **Wskaźnik wizualny**: Ikona tarczy obok nazwy użytkownika wskazuje aktywną służbę
- **Lokalizacja**: Aplikacja próbuje automatycznie pobrać lokalizację przy zakończeniu służby, ale można zakończyć służbę bez lokalizacji
- **Format daty**: Data zakończenia musi być w formacie ISO: `rrrr-MM-dd HH:mm`

---

## 5. Zakładka Usługi - Sekcja Osoby

### Opis ekranu
Zakładka "Usługi" jest drugą zakładką w aplikacji (ikona dokumentu). Zawiera sekcję "Osoby" z funkcjami sprawdzania danych osobowych i statusu osób.

![Zakładka Usługi - sekcja Osoby](images/services_tab.png)

### Przyciski w sekcji "Osoby"

#### Przycisk "Sprawdź osobę"
- **Lokalizacja**: Pierwszy przycisk w sekcji "Osoby"
- **Funkcjonalność**: Otwiera stronę wyszukiwania osób w systemie SRP

##### Strona wyszukiwania osób

![Strona wyszukiwania osób](images/persons_search_page.png)

**Pola wprowadzania danych:**

1. **PESEL**
   - **Typ klawiatury**: Klawiatura numeryczna
   - **Ograniczenia**: 
     - Akceptuje tylko cyfry (0-9)
     - Maksymalna długość: 11 cyfr
     - Licznik znaków wyświetlany po prawej stronie pola (format: `L/11`)
   - **Pomoc**: "Podaj PESEL lub (Nazwisko i Imię pierwsze). Datę w formacie yyyy-MM-dd."

2. **Nazwisko**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**: Można wyszukiwać po nazwisku i imieniu pierwszym zamiast PESEL

3. **Imię pierwsze**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**: Używane razem z nazwiskiem

4. **Imię drugie**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**

5. **Imię ojca**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**

6. **Imię matki**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**

7. **Data urodzenia (yyyy-MM-dd)**
   - **Typ klawiatury**: Klawiatura daty/czasu
   - **Format**: `yyyy-MM-dd` (np. `1990-05-15`)
   - **Opcjonalne**

8. **Data ur. od (yyyy-MM-dd)** i **Data ur. do (yyyy-MM-dd)**
   - **Typ klawiatury**: Klawiatura daty/czasu
   - **Format**: `yyyy-MM-dd`
   - **Funkcjonalność**: Pozwala wyszukiwać osoby urodzone w zakresie dat
   - **Opcjonalne**

9. **Status życia**
   - **Typ**: Lista rozwijana (Dropdown)
   - **Dostępne opcje**:
     - "Czy żyje: (nieistotne)" - nie filtruje po statusie
     - "Czy żyje: TAK" - tylko osoby żyjące
     - "Czy żyje: NIE" - tylko osoby zmarłe
   - **Domyślnie**: (nieistotne)

**Przycisk "Wyszukaj":**
- **Lokalizacja**: Na dole formularza
- **Wygląd**: Przycisk z ikoną lupy i tekstem "Wyszukaj"
- **Funkcjonalność**: 
  - Wykonuje wyszukiwanie na podstawie wprowadzonych kryteriów
  - Podczas wyszukiwania wyświetla pasek postępu
  - Jeśli znaleziono osoby, przekierowuje do strony wyników
  - Jeśli nie znaleziono, wyświetla komunikat: "Nie znaleziono osób spełniających kryteria."

**Strona wyników wyszukiwania:**

![Strona wyników wyszukiwania](images/persons_search_result_page.png)

- Wyświetla listę znalezionych osób w formie kart
- Każda karta zawiera:
  - Zdjęcie osoby (jeśli dostępne)
  - Imię i nazwisko
  - Podstawowe dane: PESEL, data urodzenia, miejsce urodzenia, płeć, status życia
  - Ostrzeżenie "⚠️ Osoba poszukiwana" (jeśli osoba jest poszukiwana)

**Przyciski na karcie osoby:**

1. **Przycisk "Szczegóły osoby"**
   - **Lokalizacja**: Pierwszy przycisk na karcie osoby
   - **Funkcjonalność**: Otwiera stronę ze szczegółowymi danymi osoby
   - **Wymagania**: Osoba musi mieć numer PESEL
   - **Obsługa błędów**: Jeśli brak PESEL, wyświetla komunikat: "Brak numeru PESEL dla tej osoby."

   ![Strona szczegółów osoby - widok 1](images/person_details_result_page_1.png)
   ![Strona szczegółów osoby - widok 2](images/person_details_result_page_2.png)
   ![Strona szczegółów osoby - widok 3](images/person_details_result_page_3.png)
   ![Strona szczegółów osoby - widok 4](images/person_details_result_page_4.png)

2. **Przycisk "Dowód osobisty"**
   - **Lokalizacja**: Drugi przycisk na karcie osoby
   - **Funkcjonalność**: Otwiera stronę z danymi dowodu osobistego osoby
   - **Wymagania**: Osoba musi mieć numer PESEL
   - **Obsługa błędów**: 
     - Jeśli brak PESEL: "Brak numeru PESEL dla tej osoby."
     - Jeśli nie udało się pobrać danych: Komunikat z serwera lub "Nie udało się pobrać danych dowodu."

   ![Strona dowodu osobistego - widok 1](images/person_id_result_page_1.png)
   ![Strona dowodu osobistego - widok 2](images/person_id_result_page_2.png)

3. **Przycisk "Czy osoba poszukiwana?"**
   - **Lokalizacja**: Trzeci przycisk na karcie osoby
   - **Funkcjonalność**: Sprawdza, czy osoba jest poszukiwana w systemie
   - **Wymagania**: Osoba musi mieć numer PESEL
   - **Wyniki**:
     - Jeśli osoba jest poszukiwana: Wyświetla pełnoekranowy czerwony splash "OSOBA POSZUKIWANA!" (migający, zamyka się automatycznie po 2.5 sekundy)
     - Jeśli osoba nie jest poszukiwana: Komunikat "Brak wpisów o poszukiwaniu."
   - **Obsługa błędów**: Komunikat z serwera lub "Błąd podczas sprawdzania poszukiwania."

   ![Splash - osoba poszukiwana](images/person_details_result_page_poszukiwany_splash.png)

4. **Przycisk "Wybierz"**
   - **Lokalizacja**: Ostatni przycisk na karcie osoby (przycisk główny)
   - **Funkcjonalność**: 
     - Zapamiętuje dane osoby do późniejszego wykorzystania
     - Przekierowuje do zakładki "Usługi" (ServicesTab)
   - **Zapamiętywanie danych**: 
     - Dane osoby są zapisywane w systemie i dostępne na innych formularzach
     - Na każdym formularzu, na którym pojawi się ikona osoby (👤), można pobrać dane wybranej osoby
     - Ikona osoby pojawia się automatycznie na formularzach wymagających PESEL (np. "Czy posiada broń prywatną?", "Czy jest żołnierzem?")
   - **Uwaga**: Po wybraniu osoby, wszystkie poprzednie strony są usuwane z historii nawigacji - użytkownik wraca do zakładki "Usługi"

#### Przycisk "Czy posiada broń prywatną?"
- **Lokalizacja**: Drugi przycisk w sekcji "Osoby"
- **Funkcjonalność**: Sprawdza, czy osoba o podanym PESEL posiada zarejestrowaną broń prywatną

##### Strona sprawdzania broni po PESEL

![Strona sprawdzania broni po PESEL](images/zw_check_weapon_holder_page.png)

**Pole wprowadzania danych:**

- **PESEL**
  - **Lokalizacja**: Główne pole formularza
  - **Typ klawiatury**: Klawiatura numeryczna (PESEL)
  - **Ograniczenia**: 
    - Akceptuje tylko cyfry (0-9)
    - Dokładnie 11 cyfr (wymagane)
  - **Walidacja**: 
    - Jeśli pole jest puste: "Podaj numer PESEL."
    - Jeśli ma mniej lub więcej niż 11 cyfr: "PESEL musi mieć 11 cyfr."
  - **Funkcja "Wypełnij z wybranej osoby"**: 
    - Ikona osoby po prawej stronie (widoczna tylko gdy wybrano osobę wcześniej)
    - Tooltip: "Wypełnij pole PESEL danymi wybranej osoby"
    - Automatycznie wypełnia pole PESEL danymi z wcześniej wybranej osoby

**Przycisk "Sprawdź":**
- **Lokalizacja**: Pod polem PESEL
- **Wygląd**: Przycisk z ikoną lupy i tekstem "Sprawdź"
- **Funkcjonalność**: 
  - Wysyła zapytanie do systemu o broń prywatną dla podanego PESEL
  - Wyświetla wynik w komunikacie na dole ekranu (SnackBar)

**Wyniki:**
- **Pozytywny wynik** (znaleziono broń):
  - Czerwony komunikat: "Osoba z PESEL = [numer] może posiadać broń: [opis]."
  
  ![Wynik pozytywny - znaleziono broń](images/zw_check_weapon_holder_page_positive.png)

- **Negatywny wynik** (nie znaleziono broni):
  - Zielony komunikat: "Znaleziono dane osoby (PESEL: [numer]), ale brak adresów z bronią."
  
  ![Wynik negatywny - brak broni](images/zw_check_weapon_holder_page_negative.png)

- **Brak danych**:
  - Zielony komunikat z informacją z serwera (np. "Nie znaleziono informacji")

#### Przycisk "Czy może być tam broń?"
- **Lokalizacja**: Trzeci przycisk w sekcji "Osoby"
- **Funkcjonalność**: Sprawdza, czy pod podanym adresem może znajdować się zarejestrowana broń prywatna

##### Strona sprawdzania broni po adresie

![Strona sprawdzania broni po adresie](images/zw_check_weapon_address_page.png)

**Pola wprowadzania danych:**

1. **Miejscowość**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Ograniczenia**: Automatyczna konwersja na wielkie litery
   - **Wymagane**: Tak

2. **Ulica**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Ograniczenia**: Automatyczna konwersja na wielkie litery
   - **Opcjonalne**

3. **Numer domu**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Ograniczenia**: Automatyczna konwersja na wielkie litery
   - **Wymagane**: Tak

4. **Numer lokalu**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Ograniczenia**: Automatyczna konwersja na wielkie litery
   - **Opcjonalne**

5. **Kod pocztowy**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**

6. **Poczta**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Ograniczenia**: Automatyczna konwersja na wielkie litery
   - **Opcjonalne**

**Informacja o wymaganych polach:**
- Na górze formularza wyświetlany jest tekst: "Wymagane pola: Miejscowość, Numer domu."

**Przycisk "Sprawdź":**
- **Lokalizacja**: Pod polami adresowymi
- **Wygląd**: Przycisk z ikoną lupy i tekstem "Sprawdź"
- **Walidacja**: 
  - Jeśli brakuje miejscowości: "Podaj miejscowość."
  - Jeśli brakuje numeru domu: "Podaj numer domu."
- **Funkcjonalność**: 
  - Wysyła zapytanie do systemu o broń prywatną pod podanym adresem
  - Wyświetla wynik w komunikacie na dole ekranu (SnackBar)

**Wyniki:**
- **Pozytywny wynik** (znaleziono broń):
  - Czerwony komunikat: "Pod podanym adresem może znajdować się broń: [opis]"
  
  ![Wynik pozytywny - znaleziono broń](images/zw_check_weapon_address_page_positive.png)

- **Negatywny wynik** (nie znaleziono broni):
  - Komunikat: "Znaleziono dane osoby (PESEL: [numer]), ale brak adresów z bronią."
  
  ![Wynik negatywny - brak broni](images/zw_check_weapon_address_page_negative.png)

- **Brak danych**:
  - Komunikat: "Nie znaleziono informacji o broni pod podanym adresem."

#### Przycisk "Czy jest żołnierzem?"
- **Lokalizacja**: Czwarty przycisk w sekcji "Osoby"
- **Funkcjonalność**: Sprawdza, czy osoba o podanym PESEL jest żołnierzem w systemie wojskowym

##### Strona sprawdzania statusu żołnierza

![Strona sprawdzania statusu żołnierza](images/zw_check_soldier_page.png)

**Pole wprowadzania danych:**

- **PESEL**
  - **Lokalizacja**: Główne pole formularza
  - **Typ klawiatury**: Klawiatura numeryczna (PESEL)
  - **Ograniczenia**: 
    - Akceptuje tylko cyfry (0-9)
    - Dokładnie 11 cyfr (wymagane)
  - **Walidacja**: 
    - Jeśli pole jest puste: "Podaj numer PESEL."
    - Jeśli ma mniej lub więcej niż 11 cyfr: "PESEL musi mieć 11 cyfr."
  - **Funkcja "Wypełnij z wybranej osoby"**: 
    - Ikona osoby po prawej stronie (widoczna tylko gdy wybrano osobę wcześniej)
    - Tooltip: "Wypełnij pole PESEL danymi wybranej osoby"
    - Automatycznie wypełnia pole PESEL danymi z wcześniej wybranej osoby

**Przycisk "Sprawdź":**
- **Lokalizacja**: Pod polem PESEL
- **Wygląd**: Przycisk z ikoną lupy i tekstem "Sprawdź"
- **Funkcjonalność**: 
  - Wysyła zapytanie do systemu wojskowego o status żołnierza dla podanego PESEL
  - Wyświetla wynik w komunikacie na dole ekranu (SnackBar)

**Wyniki:**
- **Pozytywny wynik** (znaleziono żołnierza):
  - Komunikat: "Znaleziono żołnierza: [stopień] [jednostka]"
  
  ![Wynik pozytywny - znaleziono żołnierza](images/zw_check_soldier_page_positive.png)

- **Negatywny wynik** (nie jest żołnierzem):
  - Komunikat z informacją z serwera (np. "Nie znaleziono żołnierza")
  
  ![Wynik negatywny - nie jest żołnierzem](images/zw_check_soldier_page_negative.png)

### Informacje dodatkowe

- **Integracja z wyszukiwaniem osób**: Po wybraniu osoby w funkcji "Sprawdź osobę", ikona osoby pojawia się na stronach sprawdzania broni i żołnierza, umożliwiając szybkie wypełnienie pola PESEL
- **Formaty dat**: Wszystkie daty w formularzach używają formatu `yyyy-MM-dd` (np. `1990-05-15`)
- **Komunikaty**: Wszystkie wyniki sprawdzeń wyświetlane są jako komunikaty na dole ekranu (SnackBar)
- **Kolory komunikatów**: 
  - Czerwony - znaleziono broń (ostrzeżenie)
  - Zielony - brak broni lub pozytywny wynik
  - Domyślny - informacje neutralne

---

## 6. Zakładka Usługi - Sekcja Kierowca i pojazd

### Opis ekranu
Sekcja "Kierowca i pojazd" znajduje się w zakładce "Usługi" i zawiera funkcje sprawdzania pojazdów oraz uprawnień kierowców.

![Zakładka Usługi - sekcja Kierowca i pojazd](images/services_tab_kierowca i pojazd.png)

### Przyciski w sekcji "Kierowca i pojazd"

#### Przycisk "Sprawdź pojazd"
- **Lokalizacja**: Pierwszy przycisk w sekcji "Kierowca i pojazd"
- **Funkcjonalność**: Sprawdza dane pojazdu w systemie CEP na podstawie różnych kryteriów

##### Strona sprawdzania pojazdu

![Strona sprawdzania pojazdu](images/vehicle_question_extended_page.png)

**Informacja o wymaganiach minimalnych:**
- Na górze formularza wyświetlany jest tekst z wymaganiami:
  - `typDokumentu` i `dokumentSeriaNumer` LUB
  - `numerRejestracyjny` LUB
  - `numerRejestracyjnyZagraniczny` LUB
  - `VIN` (nie łączyć z innymi)

**Pola wprowadzania danych:**

1. **Typ dokumentu**
   - **Typ**: Lista rozwijana (Dropdown)
   - **Opcjonalne**: Można wyczyścić wybór
   - **Domyślnie**: "Dowód rejestracyjny" (jeśli dostępny w słowniku)
   - **Funkcjonalność**: Lista typów dokumentów pobierana z lokalnego słownika

2. **Seria i numer dokumentu**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Ograniczenia**: 
     - Automatyczna konwersja na wielkie litery
     - Maksymalna długość: 50 znaków
   - **Opcjonalne**: Wymagane tylko w połączeniu z typem dokumentu

3. **Numer rejestracyjny (PL)**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Ograniczenia**: 
     - Automatyczna konwersja na wielkie litery
     - Maksymalna długość: 50 znaków
   - **Opcjonalne**: Można użyć zamiast dokumentu

4. **Numer rejestracyjny (zagraniczny)**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Ograniczenia**: 
     - Automatyczna konwersja na wielkie litery
     - Maksymalna długość: 50 znaków
   - **Opcjonalne**: Można użyć zamiast dokumentu lub numeru PL

5. **Numer podwozia/nadwozia/ramy (VIN)**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Ograniczenia**: 
     - Automatyczna konwersja na wielkie litery
     - Maksymalna długość: 60 znaków
   - **Opcjonalne**: Można użyć, ale nie łączyć z innymi kryteriami

**Przycisk "Wyszukaj":**
- **Lokalizacja**: Na dole formularza
- **Wygląd**: Przycisk z ikoną lupy i tekstem "Wyszukaj"
- **Walidacja**: 
  - Sprawdza, czy spełnione są wymagania minimalne
  - Jeśli nie, wyświetla komunikat z błędem walidacji
- **Funkcjonalność**: 
  - Wysyła zapytanie do systemu CEP o dane pojazdu
  - Jeśli znaleziono pojazd, przekierowuje do strony szczegółów pojazdu
  - Jeśli nie znaleziono lub wystąpił błąd, wyświetla komunikat

**Strona szczegółów pojazdu:**

![Strona szczegółów pojazdu - widok 1](images/vehicle_question_extended_response_page_1.png)
![Strona szczegółów pojazdu - widok 2](images/vehicle_question_extended_response_page_2.png)
![Strona szczegółów pojazdu - widok 3](images/vehicle_question_extended_response_page_3.png)
![Strona szczegółów pojazdu - widok 4](images/vehicle_question_extended_response_page_4.png)
![Strona szczegółów pojazdu - widok 5](images/vehicle_question_extended_response_page_5.png)
![Strona szczegółów pojazdu - widok 6](images/vehicle_question_extended_response_page_6.png)
![Strona szczegółów pojazdu - widok 7](images/vehicle_question_extended_response_page_7.png)

- Wyświetla szczegółowe dane pojazdu w rozwijanych sekcjach:
  - **Dane opisujące pojazd**: Marka, model, rodzaj, VIN, rok produkcji, itp.
  - **Dane techniczne**: Parametry techniczne pojazdu
  - **Dokumenty pojazdu**: Lista dokumentów związanych z pojazdem
  - **Informacje SKP**: Dane o stacji kontroli pojazdów i badaniach technicznych
  - **Polisa OC**: Informacje o ubezpieczeniu OC
  - **Rejestracje pojazdu**: Historia rejestracji pojazdu
  - **Podmiot (właściciel)**: Dane właściciela pojazdu

#### Przycisk "Sprawdź pojazd wojskowy"
- **Lokalizacja**: Drugi przycisk w sekcji "Kierowca i pojazd"
- **Funkcjonalność**: Wyszukuje pojazdy wojskowe w systemie WPM

##### Strona wyszukiwania pojazdu wojskowego

![Strona wyszukiwania pojazdu wojskowego](images/wpm_search_page.png)

**Informacja o wymaganiach:**
- Na górze formularza wyświetlany jest tekst: "Podaj przynajmniej jedno kryterium wyszukiwania."

**Pola wprowadzania danych:**

1. **Nr rejestracyjny**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**: Wymagane przynajmniej jedno kryterium

2. **Numer podwozia (VIN)**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**: Wymagane przynajmniej jedno kryterium

3. **Nr ser. producenta**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**: Wymagane przynajmniej jedno kryterium

4. **Nr ser. silnika**
   - **Typ klawiatury**: Klawiatura tekstowa
   - **Opcjonalne**: Wymagane przynajmniej jedno kryterium
   - **Akcja klawiatury**: Po wprowadzeniu danych i naciśnięciu "Enter", automatycznie uruchamia wyszukiwanie

**Przycisk "Szukaj":**
- **Lokalizacja**: Pod polami formularza
- **Wygląd**: Przycisk z ikoną lupy i tekstem "Szukaj"
- **Walidacja**: 
  - Jeśli wszystkie pola są puste: "Podaj przynajmniej jedno kryterium wyszukiwania."
- **Funkcjonalność**: 
  - Wysyła zapytanie do systemu WPM
  - Podczas wyszukiwania wyświetla pasek postępu
  - Jeśli znaleziono pojazdy, przekierowuje do strony wyników
  - Jeśli nie znaleziono lub wystąpił błąd, wyświetla komunikat

**Strona wyników wyszukiwania:**

![Strona wyników wyszukiwania pojazdu wojskowego](images/wpm_search_result_page.png)

- Wyświetla listę znalezionych pojazdów wojskowych w formie kart
- Każda karta zawiera podstawowe dane pojazdu (numer rejestracyjny, VIN, itp.)

#### Przycisk "Sprawdź uprawnienia kierowcy"
- **Lokalizacja**: Trzeci przycisk w sekcji "Kierowca i pojazd"
- **Funkcjonalność**: Sprawdza uprawnienia kierowcy (prawo jazdy) w systemie CEP

##### Strona sprawdzania uprawnień kierowcy

![Strona sprawdzania uprawnień - PESEL](images/upki_check_page_1.png)
![Strona sprawdzania uprawnień - dane osoby](images/upki_check_page_2.png)
![Strona sprawdzania uprawnień - numer dokumentu](images/upki_check_page_3.png)
![Strona sprawdzania uprawnień - seria i numer dokumentu](images/upki_check_page_4.png)

**Wybór sposobu wyszukiwania:**
- **Lokalizacja**: Na górze formularza
- **Typ**: Przyciski segmentowane (SegmentedButton)
- **Dostępne opcje**:
  1. **PESEL** - wyszukiwanie po numerze PESEL
  2. **Dane osoby** (ikona osoby) - wyszukiwanie po imieniu, nazwisku i dacie urodzenia
  3. **Numer dokumentu** (ikona dokumentu) - wyszukiwanie po numerze dokumentu uprawnień
  4. **Seria i numer dokumentu** (ikona karty) - wyszukiwanie po serii i numerze dokumentu (blankiet)
- **Funkcja "Wypełnij z wybranej osoby"**: 
  - Ikona osoby po prawej stronie przycisków segmentowanych (widoczna tylko gdy wybrano osobę wcześniej)
  - Tooltip: "Wypełnij pola danymi wybranej osoby"
  - Automatycznie wypełnia odpowiednie pola w zależności od wybranego sposobu wyszukiwania

**Pola wprowadzania danych (w zależności od wybranego sposobu):**

**Tryb "PESEL":**
- **PESEL**
  - **Typ klawiatury**: Klawiatura numeryczna (PESEL)
  - **Ograniczenia**: Dokładnie 11 cyfr
  - **Wymagane**: Tak

**Tryb "Dane osoby":**
- **Imię pierwsze**
  - **Typ klawiatury**: Klawiatura tekstowa
  - **Ograniczenia**: Automatyczna konwersja na wielkie litery
  - **Wymagane**: Tak
- **Nazwisko**
  - **Typ klawiatury**: Klawiatura tekstowa
  - **Ograniczenia**: Automatyczna konwersja na wielkie litery
  - **Wymagane**: Tak
- **Data urodzenia**
  - **Typ klawiatury**: Klawiatura daty
  - **Format**: `RRRR-MM-DD` (np. `1990-05-15`)
  - **Wymagane**: Tak

**Tryb "Numer dokumentu":**
- **Numer dokumentu (uprawnienia)**
  - **Typ klawiatury**: Klawiatura tekstowa
  - **Wymagane**: Tak

**Tryb "Seria i numer dokumentu":**
- **Seria i numer dokumentu (blankiet)**
  - **Typ klawiatury**: Klawiatura tekstowa
  - **Wymagane**: Tak

**Przycisk "Sprawdź uprawnienia":**
- **Lokalizacja**: Pod polami formularza
- **Wygląd**: Przycisk z ikoną lupy i tekstem "Sprawdź uprawnienia"
- **Walidacja**: 
  - Sprawdza, czy wszystkie wymagane pola są wypełnione
  - Jeśli nie, wyświetla komunikat z błędem walidacji
- **Funkcjonalność**: 
  - Wysyła zapytanie do systemu CEP o uprawnienia kierowcy
  - Jeśli znaleziono dane, przekierowuje do strony wyników
  - Jeśli nie znaleziono lub wystąpił błąd, wyświetla komunikat

**Strona wyników uprawnień kierowcy:**

![Strona wyników uprawnień - widok 1](images/upki_check_result_page_1.png)
![Strona wyników uprawnień - widok 2](images/upki_check_result_page_2.png)
![Strona wyników uprawnień - widok 3](images/upki_check_result_page_3.png)

- Wyświetla szczegółowe dane uprawnień kierowcy w rozwijanych sekcjach:
  - **Data zapytania**: Data wykonania zapytania
  - **Dane kierowcy**: PESEL, imię, nazwisko, data urodzenia, miejsce urodzenia, adres
  - **Dokumenty uprawnień kierowcy**: Lista dokumentów prawa jazdy z informacjami:
    - ID dokumentu, typ dokumentu, numer dokumentu
    - Organ wydający, data wydania, data ważności
    - Stan dokumentu i szczegóły stanu
    - Identyfikacja (Osoba ID, Wariant ID, Token kierowcy, IDK)
    - **Zakazy cofnięcia**: Wyświetlane w czerwonych ramkach z informacją o typie zdarzenia i dacie zakończenia zakazu
    - **Ograniczenia**: Lista ograniczeń z kodami i opisami
    - **Kategorie prawa jazdy**: Szczegółowe informacje o kategoriach (A, B, C, D, itp.) z datami wydania i ważności, zakazami i ograniczeniami dla każdej kategorii
    - **Komunikaty biznesowe**: Dodatkowe informacje o dokumencie

#### Przycisk "Sprawdź wykroczenia"
- **Lokalizacja**: Czwarty przycisk w sekcji "Kierowca i pojazd"
- **Funkcjonalność**: Sprawdza wykroczenia osoby w systemie KSIP. Sprawdza w Krajowym Systemie Informacji Policyjnych, czy sprawdzana osoba nie popełniła wykroczenia podlegającego przepisom dotyczącym zaostrzenia kary przy ponownym popełnieniu wykroczenia drogowego w ciągu 2 lat tj. Kodeks wykroczeń – art. 38 § 1 pkt 1a (tzw. „recydywa drogowa")
- **Wymagania uprawnień**: 
  - Dostępne tylko dla użytkowników z przypisanym `ksipUserId`
  - Jeśli użytkownik nie ma uprawnień, wyświetla komunikat: "Nie masz uprawnień do sprawdzania osób w KSIP! Skontaktuj się z przełożonym."

##### Strona sprawdzania wykroczeń

![Strona sprawdzania wykroczeń - PESEL](images/ksip_check_person_page_1.png)
![Strona sprawdzania wykroczeń - dane osoby](images/ksip_check_person_page_2.png)

**Wybór sposobu wyszukiwania:**
- **Lokalizacja**: Na górze formularza
- **Typ**: Przyciski segmentowane (SegmentedButton)
- **Dostępne opcje**:
  1. **PESEL** - wyszukiwanie po numerze PESEL
  2. **Dane osoby** (ikona osoby) - wyszukiwanie po imieniu, nazwisku i dacie urodzenia
- **Funkcja "Wypełnij z wybranej osoby"**: 
  - Ikona osoby po prawej stronie przycisków segmentowanych (widoczna tylko gdy wybrano osobę wcześniej)
  - Tooltip: "Wypełnij pola danymi wybranej osoby"
  - Automatycznie wypełnia odpowiednie pola w zależności od wybranego sposobu wyszukiwania

**Pola wprowadzania danych (w zależności od wybranego sposobu):**

**Tryb "PESEL":**
- **PESEL**
  - **Typ klawiatury**: Klawiatura numeryczna (PESEL)
  - **Ograniczenia**: Dokładnie 11 cyfr
  - **Walidacja**: 
    - Jeśli pole jest puste: "Podaj numer PESEL."
    - Jeśli ma mniej lub więcej niż 11 cyfr: "PESEL musi mieć 11 cyfr."

**Tryb "Dane osoby":**
- **Imię**
  - **Typ klawiatury**: Klawiatura tekstowa
  - **Ograniczenia**: Automatyczna konwersja na wielkie litery
  - **Walidacja**: Jeśli pole jest puste: "Podaj imię."
- **Nazwisko**
  - **Typ klawiatury**: Klawiatura tekstowa
  - **Ograniczenia**: Automatyczna konwersja na wielkie litery
  - **Walidacja**: Jeśli pole jest puste: "Podaj nazwisko."
- **Data urodzenia**
  - **Typ klawiatury**: Klawiatura daty
  - **Format**: `RRRR-MM-DD` (np. `1990-05-15`)
  - **Walidacja**: 
    - Jeśli pole jest puste: "Podaj datę urodzenia."
    - Jeśli format jest niepoprawny: "Format daty urodzenia: RRRR-MM-DD"

**Przycisk "Sprawdź osobę":**
- **Lokalizacja**: Pod polami formularza
- **Wygląd**: Przycisk z ikoną lupy i tekstem "Sprawdź osobę"
- **Walidacja**: 
  - Sprawdza, czy wszystkie wymagane pola są wypełnione
  - Jeśli nie, wyświetla komunikat z błędem walidacji
- **Funkcjonalność**: 
  - Wysyła zapytanie do systemu KSIP o wykroczenia osoby
  - Jeśli znaleziono dane, przekierowuje do strony wyników
  - Jeśli nie znaleziono lub wystąpił błąd, wyświetla komunikat

**Strona wyników sprawdzania wykroczeń:**

![Strona wyników sprawdzania wykroczeń](images/ksip_check_person_result_page.png)
![Strona wyników - brak wykroczeń](images/ksip_check_person_result_page_negative.png)

- Wyświetla dane w rozwijanych sekcjach:
  - **Dane osoby**: Imię, nazwisko, PESEL, data urodzenia
  - **Wykroczenia**: Lista wykroczeń z informacjami:
    - Data zdarzenia
    - Data zapłaty mandatu
    - Data walidacji decyzji
    - **Klasyfikacja**: Kod klasyfikacji prawnej, kod klasyfikacji, opis wykroczenia

#### Przycisk "Zarejestruj MRD5"
- **Lokalizacja**: Piąty przycisk w sekcji "Kierowca i pojazd"
- **Funkcjonalność**: Rejestracja karty MRD5 w systemie KSIP
- **Wymagania uprawnień**: 
  - Dostępne tylko dla użytkowników z przypisanym `ksipUserId`
  - Jeśli użytkownik nie ma uprawnień, wyświetla komunikat: "Nie masz uprawnień do rejestracji karty MRD5 w KSIP! Skontaktuj się z przełożonym."
- **Status**: Funkcjonalność w trakcie implementacji (TODO)

### Informacje dodatkowe

- **Integracja z wyszukiwaniem osób**: Po wybraniu osoby w funkcji "Sprawdź osobę", ikona osoby pojawia się na stronach sprawdzania uprawnień kierowcy i wykroczeń, umożliwiając szybkie wypełnienie pól formularza
- **Formaty dat**: Wszystkie daty w formularzach używają formatu `yyyy-MM-dd` lub `RRRR-MM-DD` (np. `1990-05-15`)
- **Walidacja kryteriów**: Formularze sprawdzają wymagania minimalne przed wysłaniem zapytania
- **Sekcje rozwijane**: Strony wyników używają rozwijanych sekcji (ExpansionTile), które można rozwijać i zwijać, aby zobaczyć szczegółowe informacje
- **Zakazy cofnięcia**: W wynikach uprawnień kierowcy zakazy cofnięcia wyświetlane są w czerwonych ramkach z wyraźnym oznaczeniem "ZAKAZ PROWADZENIA"

---

## Uwagi ogólne

### Nawigacja
- Wszystkie strony obsługują standardową nawigację wsteczną (przycisk "Wstecz" lub gest przesunięcia)
- Strona logowania nie ma przycisku "Wstecz" (automatycznie ukryty)

### Walidacja formularzy
- Wszystkie formularze są walidowane przed wysłaniem danych
- Komunikaty błędów wyświetlane są bezpośrednio pod odpowiednimi polami lub nad przyciskiem akcji

### Obsługa błędów
- Błędy sieciowe i serwerowe wyświetlane są jako komunikaty tekstowe
- W przypadku błędów użytkownik może spróbować ponownie po poprawieniu danych

### Bezpieczeństwo
- Wszystkie pola PIN są ukryte podczas wprowadzania
- Kod bezpieczeństwa jest wymagany do resetu PIN-u i musi być wygenerowany przez uprawnionego supervisora

