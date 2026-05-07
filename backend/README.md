# Field Notebook — backend

Backend w Bun + Hono + SQLite dla aplikacji iOS Field Service Technician.

## Lokalny rozwój

```bash
cd backend
bun install
bun run migrate     # tworzy ./data/app.db wraz ze schematem
bun run seed        # wstawia 4 testowych techników i ich zlecenia
bun run dev         # http://localhost:3000
```

## Konta testowe (wszystkie z hasłem `test1234`)

| Email | Nazwa wyświetlana | Scenariusz |
|---|---|---|
| `marek@firma.pl` | Marek Kowalski (elektryk) | 8 zleceń, 3 zamknięte + 5 otwartych — `default` |
| `anna@firma.pl`  | Anna Nowak (hydraulik)    | 6 zleceń; klient iOS symuluje tryb offline   |
| `piotr@firma.pl` | Piotr Wójcik (klimatyzacja) | 5 zleceń + 1 z `is_new=1` — `new` |
| `kasia@firma.pl` | Katarzyna Zielińska (ogólne) | 8 zleceń, wszystkie zamknięte — `empty`           |

## Testy

```bash
bun test
```

Testy działają na bazie SQLite w pamięci — nie modyfikują katalogu `./data/`.

## Wdrożenie

Coolify na RPi konsumuje `docker-compose.yml`. Wolumin `field-notebook-data` zachowuje `app.db` i przesłane zdjęcia między kolejnymi wdrożeniami.

Wymagane zmienne środowiskowe w panelu Coolify:
- `JWT_SECRET` — co najmniej 32 znaki, ustawiany JEDNOKROTNIE przy wdrożeniu i nie rotowany bez wymuszonego globalnego wylogowania użytkowników.

## Lista kontrolna po wdrożeniu

- [ ] `curl https://<host>/health` → `{"ok":true}`
- [ ] `POST /auth/login` z `marek@firma.pl` / `test1234` → 200 z `accessToken` i `refreshToken`
- [ ] `GET /jobs` z bearer → 8 wpisów, żaden nie należy do innego technika
- [ ] `POST /jobs/<id>/start` → status zmienia się na `in_progress`
- [ ] `POST /jobs/<id>/photos` z 1×1 JPEG → 201
- [ ] 5× błędne hasło → 423 przy 6. próbie dla danego konta

## Wdrożenia

Redeploy uruchamiaj ręcznie z panelu Coolify (projekt `mirek-rpi` → `field-notebook-backend` → Deploy). Aplikacja GitHub Coolify jest zainstalowana, ale automatyczne wdrażanie wyzwalane pushem jest obecnie wyłączone; żaden workflow GitHub Actions nie bierze udziału we wdrożeniu.
