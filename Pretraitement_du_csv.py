import pandas as pd
import numpy as np
from datetime import datetime
import chardet

class DataCleaner:
    def __init__(self, file_path):
        # Détecter l'encodage du fichier
        encoding = self.detect_encoding(file_path)
        print(f"Encodage détecté: {encoding}")
        
        # Lire le fichier avec l'encodage approprié
        self.df = pd.read_csv(file_path, encoding=encoding)
        self.original_shape = self.df.shape
        
    def detect_encoding(self, file_path, sample_size=10000):
        """Détecter l'encodage du fichier"""
        with open(file_path, 'rb') as f:
            raw_data = f.read(sample_size)
            result = chardet.detect(raw_data)
            encoding = result['encoding']
            confidence = result['confidence']
            print(f"Encodage détecté: {encoding} (confiance: {confidence:.2%})")
            
            # Si la confiance est faible, essayer les encodages courants
            if confidence < 0.7:
                print("Confiance faible, essai des encodages courants...")
                common_encodings = ['latin-1', 'iso-8859-1', 'cp1252', 'utf-8']
                for enc in common_encodings:
                    try:
                        pd.read_csv(file_path, encoding=enc, nrows=5)
                        print(f"Encodage {enc} fonctionne")
                        return enc
                    except:
                        continue
                
            return encoding
    
    def remove_row_id(self):
        """Supprimer la colonne Row ID si elle existe"""
        if 'Row ID' in self.df.columns:
            self.df = self.df.drop(columns=['Row ID'])
            print("Colonne 'Row ID' supprimée")
        return self
    
    def clean_text_columns(self):
        """Nettoyer les colonnes texte"""
        text_columns = ['Ship Mode', 'Customer ID', 'Customer Name', 'Segment', 
                       'Country', 'City', 'State', 'Postal Code', 'Region', 
                       'Product ID', 'Category', 'Sub-Category', 'Product Name']
        
        for col in text_columns:
            if col in self.df.columns:
                self.df[col] = self.df[col].astype(str).str.strip()
        
        return self
    
    def convert_dates(self):
        """Convertir les dates du format M/J/AAAA"""
        def parse_date(date_str):
            try:
                if pd.isna(date_str):
                    return pd.NaT
                if isinstance(date_str, str) and '/' in date_str:
                    month, day, year = date_str.split('/')
                    return datetime(int(year), int(month), int(day))
                return pd.to_datetime(date_str, errors='coerce')
            except:
                return pd.NaT
        
        self.df['Order Date'] = self.df['Order Date'].apply(parse_date)
        self.df['Ship Date'] = self.df['Ship Date'].apply(parse_date)
        
        return self
    
    def clean_numeric_columns(self):
        """Nettoyer les colonnes numériques"""
        numeric_cols = ['Sales', 'Quantity', 'Discount', 'Profit']
        for col in numeric_cols:
            if col in self.df.columns:
                self.df[col] = pd.to_numeric(self.df[col], errors='coerce')
        
        return self
    
    def remove_invalid_rows(self):
        """Supprimer les lignes invalides"""
        # Supprimer les lignes avec dates manquantes
        self.df = self.df.dropna(subset=['Order Date', 'Ship Date'])
        
        # Supprimer les lignes avec IDs manquants
        self.df = self.df.dropna(subset=['Order ID', 'Customer ID', 'Product ID'])
        
        # Supprimer les lignes où Ship Date < Order Date
        self.df = self.df[self.df['Ship Date'] >= self.df['Order Date']]
        
        return self
    
    def standardize_regions(self):
        """Standardiser les noms de régions"""
        region_map = {
            'WEST': 'West', 'west': 'West',
            'EAST': 'East', 'east': 'East',
            'SOUTH': 'South', 'south': 'South',
            'CENTRAL': 'Central', 'central': 'Central'
        }
        self.df['Region'] = self.df['Region'].replace(region_map)
        return self
    
    def clean_product_names(self):
        """Nettoyer les noms de produits"""
        if 'Product Name' in self.df.columns:
            self.df['Product Name'] = (
                self.df['Product Name']
                .astype(str)
                .str.replace('\u00a0', ' ')      # Espace insécable
                .str.replace('"', '')            # Guillemets doubles
                .str.replace("'", "")            # Guillemets simples
                .str.replace(' +', ' ', regex=True)  # Espaces multiples
                .str.strip()
            )
        return self
    
    def get_cleaning_report(self):
        """Générer un rapport de nettoyage"""
        return {
            'original_rows': self.original_shape[0],
            'cleaned_rows': len(self.df),
            'rows_removed': self.original_shape[0] - len(self.df),
            'remaining_columns': len(self.df.columns),
            'date_range_order': (self.df['Order Date'].min(), self.df['Order Date'].max()),
            'date_range_ship': (self.df['Ship Date'].min(), self.df['Ship Date'].max())
        }
    
    def show_date_statistics(self):
        """Afficher les statistiques des dates"""
        print("\n=== STATISTIQUES DES DATES ===")
        print(f"Date de commande la plus ancienne: {self.df['Order Date'].min()}")
        print(f"Date de commande la plus récente: {self.df['Order Date'].max()}")
        print(f"Date d'expédition la plus ancienne: {self.df['Ship Date'].min()}")
        print(f"Date d'expédition la plus récente: {self.df['Ship Date'].max()}")
        
        # Calculer la durée couverte
        date_range_days = (self.df['Order Date'].max() - self.df['Order Date'].min()).days
        print(f"Période couverte: {date_range_days} jours")
        
        # Calculer le délai moyen d'expédition
        shipping_time = (self.df['Ship Date'] - self.df['Order Date']).dt.days
        print(f"Délai moyen d'expédition: {shipping_time.mean():.2f} jours")
        
        return self
    
    def save_cleaned_data(self, output_path):
        """Sauvegarder les données nettoyées"""
        self.df.to_csv(output_path, index=False, encoding='utf-8')
        print(f"Données sauvegardées dans {output_path}")
    
    def execute_cleaning(self):
        """Exécuter tout le processus de nettoyage"""
        print("Début du nettoyage des données...")
        
        (self.remove_row_id()
         .clean_text_columns()
         .convert_dates()
         .clean_numeric_columns()
         .standardize_regions()
         .clean_product_names()
         .remove_invalid_rows())
        
        report = self.get_cleaning_report()
        print("Nettoyage terminé!")
        print(f"Lignes originales: {report['original_rows']}")
        print(f"Lignes après nettoyage: {report['cleaned_rows']}")
        print(f"Lignes supprimées: {report['rows_removed']}")
        
        # Afficher les statistiques des dates
        self.show_date_statistics()
        
        return self

# Utilisation
if __name__ == "__main__":
    # Initialiser le nettoyeur
    cleaner = DataCleaner('Sample - Superstore.csv')
    
    # Exécuter le nettoyage
    cleaner.execute_cleaning()
    
    # Sauvegarder les données nettoyées
    cleaner.save_cleaned_data('Superstore_Clean.csv')
    
    # Aperçu des données nettoyées
    print("\nAperçu des données nettoyées:")
    print(cleaner.df.head())
    print(f"\nTypes de données:\n{cleaner.df.dtypes}")
    print(f"\nShape final: {cleaner.df.shape}")