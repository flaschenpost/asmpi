#include <stdio.h>
#include <stdlib.h>
#include <gmp.h>
#include <time.h>

// Berechnet: term = (basis_wert / x) - (basis_wert / 3*x^3) + (basis_wert / 5*x^5) - ...
void berechne_arctan_reihe(mpz_t result, mpz_t basis_wert, unsigned long x) {
    mpz_t aktueller_term, divisor, x_quadrat;
    mpz_init(aktueller_term);
    mpz_init(divisor);
    mpz_init(x_quadrat);

    unsigned long n = 1;
    unsigned long x_quadrat_num = x * x;

    // Erster Term: basis_wert / x
    mpz_fdiv_q_ui(aktueller_term, basis_wert, x);
    mpz_set(result, aktueller_term);

    // Schleife läuft, bis der aktuelle Term 0 wird (Präzisionsgrenze erreicht)
    while (mpz_cmp_ui(aktueller_term, 0) > 0) {
        // Nächsten Teiler für x berechnen: aktueller_term = aktueller_term / x^2
        mpz_fdiv_q_ui(aktueller_term, aktueller_term, x_quadrat_num);

        // Der Nenner der Taylor-Reihe erhöht sich um 2 (1, 3, 5, 7...)
        n += 2;
        mpz_fdiv_q_ui(divisor, aktueller_term, n);

        // Abwechselnd addieren und subtrahieren
        if ((n / 2) % 2 == 1) {
            mpz_sub(result, result, divisor);
        } else {
            mpz_add(result, result, divisor);
        }
    }

    // Speicher freigeben
    mpz_clear(aktueller_term);
    mpz_clear(divisor);
    mpz_clear(x_quadrat);
}

int main() {
    // Gewünschte Nachkommastellen (dezimal)
    unsigned long stellen = 1000000; 
    printf("Berechne %lu Stellen von Pi...\n", stellen);

    clock_t start = clock();

    // GMP Variablen initialisieren
    mpz_t basis_wert, term1, term2, pi;
    mpz_init(basis_wert);
    mpz_init(term1);
    mpz_init(term2);
    mpz_init(pi);

    // Wir verschieben das Komma gedanklich nach rechts, indem wir 10^stellen berechnen
    // basis_wert = 10^(stellen + 10) -- 10 "Sicherheitsstellen" gegen Rundungsfehler
    mpz_ui_pow_ui(basis_wert, 10, stellen + 10);

    // Machin Formel: Pi = 4 * [ 4 * arctan(1/5) - arctan(1/239) ]
    // Umgestellt für Ganzzahlen: Pi = 16 * arctan(1/5) - 4 * arctan(1/239)

    // 1. Term: 16 * arctan(1/5) -> Wir multiplizieren die Basis vorab mit 16
    mpz_t basis_term1;
    mpz_init_set(basis_term1, basis_wert);
    mpz_mul_ui(basis_term1, basis_term1, 16);
    berechne_arctan_reihe(term1, basis_term1, 5);

    // 2. Term: 4 * arctan(1/239) -> Wir multiplizieren die Basis vorab mit 4
    mpz_t basis_term2;
    mpz_init_set(basis_term2, basis_wert);
    mpz_mul_ui(basis_term2, basis_term2, 4);
    berechne_arctan_reihe(term2, basis_term2, 239);

    // Pi = Term1 - Term2
    mpz_sub(pi, term1, term2);

    // Die 10 Sicherheitsstellen wieder entfernen (durch 10^10 teilen)
    mpz_t sicherheits_teiler;
    mpz_init_set_ui(sicherheits_teiler, 10);
    mpz_pow_ui(sicherheits_teiler, sicherheits_teiler, 10);
    mpz_tdiv_q(pi, pi, sicherheits_teiler);

    clock_t end = clock();
    double zeit = (double)(end - start) / CLOCKS_PER_SEC;

    // Ergebnis ausgeben (Als String konvertieren)
    char *pi_str = mpz_get_str(NULL, 10, pi);
    
    // Schön formatiert ausgeben (3.14...)
    printf("Zeit: %.4f Sekunden\n", zeit);
    printf("Ergebnis (erste 50 Stellen): %.1s,%50s...\n", pi_str, pi_str + 1);

    // Speicher aufräumen
    free(pi_str);
    mpz_clear(basis_wert);
    mpz_clear(basis_term1);
    mpz_clear(basis_term2);
    mpz_clear(term1);
    mpz_clear(term2);
    mpz_clear(sicherheits_teiler);
    mpz_clear(pi);

    return 0;
}
