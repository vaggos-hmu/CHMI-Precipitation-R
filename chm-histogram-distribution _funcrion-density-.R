# 1. ΠΡΟΕΤΟΙΜΑΣΙΑ ΔΕΔΟΜΕΝΩΝ ΓΙΑ ΕΝΑΝ ΣΤΑΘΜΟ
# Προσθέτουμε τον κανόνα: LOKALITA_NAZEV == "Modletín" 
# (Προσοχή: Πρέπει να γραφτεί ακριβώς όπως είναι στον πίνακα, με τον τόνο στο í)
rain_station <- dta_prec$VALUE[dta_prec$VELICINA_ZKRATKA == "rain" & 
                               dta_prec$LOKALITA_NAZEV == "Modletín" & 
                               dta_prec$VALUE > 0]

# Αφαιρούμε τα κενά
rain_station <- na.omit(rain_station)


# 2. ΙΣΤΟΓΡΑΜΜΑ (Histogram) για τον ένα σταθμό
hist(rain_station, 
     main = "Ιστόγραμμα Βροχόπτωσης - Modletín", 
     xlab = "Χιλιοστά Βροχής (mm)",    
     ylab = "Συχνότητα (Ημέρες)",      
     col = "lightblue",                
     breaks = 30)                      


# 3. ΚΑΜΠΥΛΗ ΠΥΚΝΟΤΗΤΑΣ (Density)
plot(density(rain_station), 
     main = "Καμπύλη Πυκνότητας - Modletín", 
     xlab = "Χιλιοστά Βροχής (mm)", 
     ylab = "Πυκνότητα",
     col = "blue", 
     lwd = 2) 


# 4. ΣΥΝΑΡΤΗΣΗ ΚΑΤΑΝΟΜΗΣ (Distribution Function)
plot(ecdf(rain_station), 
     main = "Αθροιστική Κατανομή - Modletín", 
     xlab = "Χιλιοστά Βροχής (mm)", 
     ylab = "Πιθανότητα (0 έως 1)",
     col = "darkblue",
     lwd = 2)
