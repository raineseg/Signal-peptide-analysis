library(data.table)
library(stringi)
library(stringr)
library(ggplot2)

data <- fread('/home/evgenii/refseq/bacteria/allpredictions.txt')
# colnames(data)

# filter proteins with signal peptide 
data_filtered <- data[Prediction != "OTHER", ]

#delete useless symbols
data_filtered$cleav_site <- gsub("CS pos: ", "", data_filtered$`CS Position`)
# extracting the last aminoacid in mature proteins
data_filtered$cleav_site <- sapply(data_filtered$cleav_site, function(x) strsplit(x, "-")[[1]][1])
# making column with sequence of mature proteins
data_filtered$cleav_site = as.numeric(data_filtered$cleav_site)
data_filtered$cleaved_protein <- substr(data_filtered$sequence, data_filtered$cleav_site + 1, 
                                        length(data_filtered$sequence))

window <- 16
data_filtered$cleaved_protein_N_term_16 <- substr(data_filtered$cleaved_protein, 1, window)

window <- 50
data_filtered$cleaved_protein_N_term_50 <- substr(data_filtered$cleaved_protein, 1, window)

# counting the charge
# arginine, lysine +1 (R ,K)
# aspartate, glutamate -1 (D, E)
data_filtered$charge_16 <- str_count(data_filtered$cleaved_protein_N_term_16, "R") +
  str_count(data_filtered$cleaved_protein_N_term_16, "K") - 
  str_count(data_filtered$cleaved_protein_N_term_16, "D") - 
  str_count(data_filtered$cleaved_protein_N_term_16, "E")

data_filtered$charge_50 <- str_count(data_filtered$cleaved_protein_N_term_50, "R") +
  str_count(data_filtered$cleaved_protein_N_term_50, "K") - 
  str_count(data_filtered$cleaved_protein_N_term_50, "D") - 
  str_count(data_filtered$cleaved_protein_N_term_50, "E")


#data_filtered[Prediction == "LIPO(Sec/SPII)", .N, by = charge_16]

# histogram
ggplot(data_filtered, aes(x = charge_16))+
  geom_histogram(binwidth = 1, fill="black", col="grey") +
  facet_wrap(~ Prediction) +
  theme_bw() +
  labs(x = "Net charge", y = "Sequence count", title = "Net charge distributions in the N-terminal 16-residue region")

ggplot(data_filtered, aes(x = charge_50))+
  geom_histogram(binwidth = 1, fill="black", col="grey") +
  facet_wrap(~ Prediction) +
  theme_bw() +
  labs(x = "Net charge", y = "Sequence count", title = "Net charge distributions in the N-terminal 50-residue region")
                                            
