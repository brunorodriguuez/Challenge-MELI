import requests  # Importa la biblioteca para hacer solicitudes HTTP
import csv      # Importa la biblioteca para trabajar con archivos CSV
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Ejercicio 1: Barrer una lista de más de 150 ítems ids en el servicio público


def buscar_items(termino_busqueda, limite=50, offset=0):
    url = f"https://api.mercadolibre.com/sites/MLA/search?q={termino_busqueda}&limit={limite}&offset={offset}"
    response = requests.get(url)
    if response.status_code == 200:
        resultados = response.json().get("results", [])

        return [item["id"] for item in resultados] # Lista con los IDs de los ítems de la lista de resultados
    else:
        print(f"Error al buscar ítems: {response.status_code}")
        return []


terminos_busqueda = ["Google Home", "Apple TV", "Amazon Fire TV"] # Lista de términos de búsqueda

for termino in terminos_busqueda:  #Inicio de bucle para iterar sobre cada término de búsqueda en la lista.
    ids_totales = []
    offset = 0
    cantidad_deseada = 151

    while len(ids_totales) < cantidad_deseada: # Inicia un bucle while que continúa hasta que se hayan obtenido al menos 151 IDs de ítems o hasta que no haya más resultados.
        ids = buscar_items(termino, offset=offset)
        if not ids:
            break
        ids_totales.extend(ids)
        offset += 50

    print(f"Se obtuvieron {len(ids_totales)} IDs para '{termino}'.")



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# --- Punto 2 y 3: Obtener detalles de cada ítem y guardar en CSV ---

# URL base para obtener detalles de un producto por su ID
item_url = "https://api.mercadolibre.com/items/{}"

def buscar_item_detalle(item_id):
    """
    Obtiene los detalles de un producto específico usando su ID.
    Retorna la información en formato JSON.
    """
    response = requests.get(item_url.format(item_id))  # Realiza la solicitud HTTP
    return response.json()  # Devuelve la respuesta como un diccionario JSON

def crear_csv(data, filename="challenge_mercadolibre.csv"):
    """
    Guarda los datos en un archivo CSV.
    La primera fila contiene los nombres de las columnas.
    """
    if not data:
        print("No hay datos para guardar en CSV.")
        return

    keys = data[0].keys()  # Obtiene las claves del primer elemento (columnas del CSV)
    
    with open(filename, "w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=keys)  # Configura el escritor de CSV con las claves
        writer.writeheader()  # Escribe los encabezados de columna
        writer.writerows(data)  # Escribe los datos en filas

def main():
    """
    Función principal:
    - Busca productos en Mercado Libre según los términos especificados.
    - Obtiene los detalles de cada producto encontrado.
    - Guarda los resultados en un archivo CSV.
    """
    all_data = []  # Lista para almacenar la información de todos los productos
    
    for term in terminos_busqueda:
        print(f"Buscando ítems para: {term}")  # Mensaje de estado
        item_ids = buscar_items(term)  # Obtiene los IDs de los productos
        
        for item_id in item_ids:
            print(f"Obteniendo detalles de {item_id}")  # Mensaje de estado
            details = buscar_item_detalle(item_id)  # Obtiene los detalles del producto
            all_data.append(details)  # Agrega la información a la lista
    
    # Desnormalizar JSON: Seleccionar y organizar las claves más relevantes para el CSV
    normalized_data = [
        {
            "ID": item.get("id"),  # Cambiado a "ID"
            "Título del producto": item.get("title"),  # Cambiado a "Título"
            "Precio": item.get("price"),  # Cambiado a "Precio"
            "Moneda": item.get("currency_id"),  # Cambiado a "Moneda"
            "Condición": item.get("condition"),  # Cambiado a "Condición"
            "Enlace": item.get("permalink")  # Cambiado a "Enlace Permanente"
        }
        for item in all_data
    ]
    
    # Guardar los datos en CSV
    crear_csv(normalized_data)
    print("Datos guardados en mercadolibre_items.csv")

# Ejecutar el script 
if __name__ == "__main__":
    main()
