# 1. ΟΡΙΣΜΟΣ ΔΙΕΥΘΥΝΣΕΩΝ (Πού ψάχνουμε και πού αποθηκεύουμε)
url <- "https://opendata.chmi.cz/air_quality/historical/precipitation/"
pth <- "C:/Users/vagge/Downloads/"

# 2. ΑΝΑΓΝΩΣΗ ΤΗΣ ΙΣΤΟΣΕΛΙΔΑΣ
# Το test_1 απέτυχε γιατί η scan() έψαχνε μόνο αριθμούς, ενώ η σελίδα έχει κείμενο.
# test_1 <- scan(file = url) 

# Το test_2 πετυχαίνει: Λέμε στην R να διαβάσει τον κώδικα της σελίδας ως κείμενο/λίστα.
test_2 <- scan(file = url, what = "list")

# 3. ΕΥΡΕΣΗ ΤΟΥ ΟΝΟΜΑΤΟΣ ΤΟΥ ΑΡΧΕΙΟΥ ZIP
# Ψάχνουμε (grep) μέσα στο κείμενο της σελίδας για τη λέξη "data".
# Μετά σπάζουμε (strsplit) το αποτέλεσμα στα εισαγωγικά (") για να κρατήσουμε 
# μόνο το καθαρό όνομα του αρχείου (Data_precipitation_1976_2025.zip).
fl_nm <- strsplit(x = test_2[grep(pattern = "data", 
                                  x = test_2, 
                                  ignore.case = TRUE)],
                  split = '\"')[[1]][2]

# 4. ΚΑΤΕΒΑΣΜΑ ΤΟΥ ΑΡΧΕΙΟΥ
# Ενώνουμε το url με το όνομα του αρχείου και το κατεβάζουμε στον υπολογιστή μας.
download.file(url = paste0(url, fl_nm),
              destfile = paste0(pth, fl_nm))

# 5. ΔΗΜΙΟΥΡΓΙΑ ΦΑΚΕΛΟΥ ΚΑΙ ΑΠΟΣΥΜΠΙΕΣΗ
# Φτιάχνουμε (dir.create) έναν νέο φάκελο με το όνομα "data" μέσα στα Downloads.
dir.create(path = paste0(pth, "data"))

# Ξεπακετάρουμε (unzip) το μεγάλο κεντρικό zip αρχείο μέσα στον νέο φάκελο "data".
unzip(zipfile = paste0(pth, fl_nm),
      exdir = paste0(pth, "data"))

# 6. ΧΑΡΤΟΓΡΑΦΗΣΗ ΤΩΝ ΕΣΩΤΕΡΙΚΩΝ ΑΡΧΕΙΩΝ
# Ψάχνουμε μέσα στον φάκελο "data" και στους υποφακέλους του (recursive = TRUE).
fls <- list.files(path = paste0(pth, "data"), 
                  recursive = TRUE,
                  full.names = TRUE)

# Κρατάμε από τη λίστα ΜΟΝΟ τα αρχεία που τελειώνουν σε ".zip". 
# Έτσι προκύπτει η τελική λίστα με τα 17.509 αρχεία των σταθμών.
fls_zip <- fls[grep(pattern = "\\.zip$", 
                    x = fls, 
                    ignore.case = TRUE)]

# 7. ΔΙΑΒΑΣΜΑ ΚΑΙ ΕΝΩΣΗ ΔΕΔΟΜΕΝΩΝ (Ο αυτοματοποιημένος "Εργάτης" lapply)
# Το lapply παίρνει ΕΝΑ-ΕΝΑ τα 17.509 zip αρχεία και εκτελεί τις εντολές που ακολουθούν:
dta_prec <- lapply(
  X = fls_zip, 
  FUN = function(x) {
    
    # Το try λειτουργεί σαν δίχτυ ασφαλείας. Αν ένα zip είναι χαλασμένο, 
    # ο κώδικας δεν θα κρασάρει, απλώς θα πάει στο επόμενο (silent = TRUE).
    e <- try(expr = {
      
      # Φτιάχνει έναν προσωρινό φάκελο στη μνήμη (tempdir) και ξεπακετάρει το zip εκεί.
      tmp <- tempdir()
      unzip(zipfile = x, exdir = tmp)
      
      # Βρίσκει ποια αρχεία (.csv) βγήκαν μόλις από το zip του σταθμού.
      aux_fls <- list.files(path = tmp, full.names = TRUE)
      
      # Διαβάζει το csv με τις μετρήσεις βροχής (αυτό που έχει τη λέξη "data" στο όνομά του).
      dta <- read.csv(file = aux_fls[grep(pattern = "data", x = aux_fls)])
      
      # Διαβάζει το csv με τα στοιχεία του σταθμού (έχει τη λέξη "registr").
      nfo <- read.csv(file = aux_fls[grep(pattern = "registr", x = aux_fls)])
      
      # Ενώνει τις στήλες των μετρήσεων με τις στήλες του σταθμού (Column Bind).
      out <- cbind(dta, nfo)
    }, 
    silent = TRUE)
    
    # Αν το αρχείο ήταν χαλασμένο (βρέθηκε σφάλμα), βάλε αποτέλεσμα NA (Not Available)
    if (inherits(x = e, what = "try-error")) {
      out <- NA
    } 
    
    out # Το αποτέλεσμα επιστρέφεται στη λίστα
  }
)

# 8. ΔΗΜΙΟΥΡΓΙΑ ΤΟΥ ΤΕΛΙΚΟΥ ΜΕΓΑΛΟΥ ΠΙΝΑΚΑ
# Ενώνει όλους τους μικρούς πίνακες βάζοντάς τους τον έναν ΚΑΤΩ από τον άλλον (Row Bind - rbind),
# πετώντας τα άδεια αρχεία (!is.na). Έτσι προκύπτουν οι 800.000 γραμμές!
dta_prec <- do.call(what = rbind,
                    args = dta_prec[!is.na(x = dta_prec)])


# 9. ΑΠΟΘΗΚΕΥΣΗ ΔΕΔΟΜΕΝΩΝ (ΠΟΛΥ ΣΗΜΑΝΤΙΚΟ)
# Σώζουμε τον τελικό πίνακα στον υπολογιστή μας. 
# Την επόμενη φορά δεν θα ξανατρέξουμε τίποτα από τα παραπάνω, 
# απλώς θα φορτώσουμε αυτό το αρχείο!
saveRDS(object = dta_prec, file = paste0(pth, "dta_prec_final.rds"))
