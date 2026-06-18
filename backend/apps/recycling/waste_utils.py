"""
Utilidades para mapeo de residuos a canecas y respuestas ecológicas.
Sistema de 4 canecas: AZUL, BLANCO, VERDE, GRIS
"""

# Mapeo automático de categorías de residuos a canecas
RESIDUO_A_CANECA = {
    'carton': {
        'caneca': 'Caneca Blanca',
        'color': 'white',
        'consejo': '♻️ El cartón tarda 5 años en degradarse. Apláncalo para ahorrar espacio.',
        'descripcion': 'Papel y cartón',
    },
    'papel': {
        'caneca': 'Caneca Blanca',
        'color': 'white',
        'consejo': '📄 El papel reciclado ahorra agua y energía. ¡Sepáralo siempre!',
        'descripcion': 'Papel',
    },
    'plastico': {
        'caneca': 'Caneca Azul',
        'color': 'blue',
        'consejo': '🔵 El plástico tarda 500 años en desaparecer. Recíclalo en la Caneca Azul.',
        'descripcion': 'Plástico y envases',
    },
    'vidrio': {
        'caneca': 'Caneca Blanca',
        'color': 'white',
        'consejo': '🥤 El vidrio es 100% reciclable. Colócalo en la Caneca Blanca.',
        'descripcion': 'Vidrio y botellas',
    },
    'metal': {
        'caneca': 'Caneca Blanca',
        'color': 'white',
        'consejo': '⚙️ Los metales se reciclan indefinidamente sin perder calidad. ¡Guárdalos!',
        'descripcion': 'Metales y aluminio',
    },
    'organico': {
        'caneca': 'Caneca Verde',
        'color': 'green',
        'consejo': '🍎 Los residuos orgánicos se pueden compostar. Ayuda a hacer abono para plantas.',
        'descripcion': 'Residuos orgánicos y comida',
    },
    'electronico': {
        'caneca': 'Caneca Gris',
        'color': 'gray',
        'consejo': '⚡ Los electrónicos contienen materiales valiosos y tóxicos. Llévalo a un punto de acopio.',
        'descripcion': 'Residuos electrónicos',
    },
    'textil': {
        'caneca': 'Caneca Gris',
        'color': 'gray',
        'consejo': '👕 La ropa usada puede donarse o reciclarse. Considera reutilizar primero.',
        'descripcion': 'Textiles y ropa',
    },
}

# Mapeo inverso: de canecas a categorías
CANECA_A_RESIDUOS = {
    'Caneca Azul': ['plastico'],
    'Caneca Blanca': ['carton', 'papel', 'vidrio', 'metal'],
    'Caneca Verde': ['organico'],
    'Caneca Gris': ['electronico', 'textil'],
}

def obtener_caneca_para_residuo(categoria):
    """
    Retorna la caneca apropiada para una categoría de residuo.
    
    Args:
        categoria (str): Categoría del residuo (ej: 'plastico', 'organico')
    
    Returns:
        dict: Información de la caneca {caneca, color, consejo, descripcion}
    """
    return RESIDUO_A_CANECA.get(
        categoria.lower(),
        {
            'caneca': 'Caneca Gris',
            'color': 'gray',
            'consejo': '♻️ Residuo no clasificado. Deposítalo en Caneca Gris.',
            'descripcion': 'Residuos varios',
        }
    )


def generar_respuesta_ecologica(categoria, nombre_usuario='Reciclador'):
    """
    Genera una respuesta ecológica basada en la categoría de residuo.
    Fallback determinista cuando no hay Gemini.
    
    Args:
        categoria (str): Categoría del residuo
        nombre_usuario (str): Nombre del usuario
    
    Returns:
        str: Respuesta formateada
    """
    info = obtener_caneca_para_residuo(categoria)
    
    respuesta = f"""CONSEJO: {info['consejo']}
CANECA: {info['caneca']}"""
    
    return respuesta


def obtener_tips_sobre_canecas():
    """Retorna tips educativos sobre las 4 canecas."""
    return {
        'Caneca Azul': {
            'descripcion': 'Plástico y envases',
            'items': ['Botellas de plástico', 'Bolsas plásticas', 'Envases de alimentos', 'Juguetes de plástico'],
            'no_incluir': ['Bolsas de una sola capa', 'Plástico sucio']
        },
        'Caneca Blanca': {
            'descripcion': 'Papel, cartón, vidrio y metales',
            'items': ['Cajas de cartón', 'Periódicos', 'Botellas de vidrio', 'Latas de aluminio', 'Frascos de vidrio'],
            'no_incluir': ['Vidrio roto', 'Papel mojado', 'Cartón con grasa']
        },
        'Caneca Verde': {
            'descripcion': 'Residuos orgánicos',
            'items': ['Cáscaras de frutas', 'Hoja y ramas', 'Restos de comida', 'Aserrín', 'Cáscaras de huevo'],
            'no_incluir': ['Carne cocida', 'Aceites', 'Productos lácteos']
        },
        'Caneca Gris': {
            'descripcion': 'Residuos peligrosos y no reciclables',
            'items': ['Electrónicos', 'Pilas y baterías', 'Ropa dañada', 'Cerámicas', 'Espejo roto'],
            'no_incluir': ['Nada de lo anterior']
        }
    }


def clasificar_item_a_caneca(item_nombre):
    """
    Clasifica un item a una caneca basado en palabras clave.
    
    Args:
        item_nombre (str): Nombre del item (ej: 'botella plástica')
    
    Returns:
        str: Nombre de la caneca
    """
    item = item_nombre.lower()
    
    # Palabras clave para Caneca Azul (Plástico)
    if any(palabra in item for palabra in ['plástico', 'botella plastica', 'bolsa plastica', 'envase de plastico', 'juguete']):
        return 'Caneca Azul'
    
    # Palabras clave para Caneca Blanca (Papel, cartón, vidrio, metal)
    if any(palabra in item for palabra in ['papel', 'periódico', 'cartón', 'caja', 'vidrio', 'botella vidrio', 'lata', 'aluminio', 'metal', 'frascos']):
        return 'Caneca Blanca'
    
    # Palabras clave para Caneca Verde (Orgánico)
    if any(palabra in item for palabra in ['fruta', 'verdura', 'comida', 'cascaras', 'hoja', 'rama', 'aserrín', 'organico', 'orgánico']):
        return 'Caneca Verde'
    
    # Palabras clave para Caneca Gris (Otros)
    if any(palabra in item for palabra in ['electrónico', 'electronico', 'pila', 'bateria', 'ropa', 'ceramica', 'vidrio roto', 'espejo']):
        return 'Caneca Gris'
    
    # Por defecto
    return 'Caneca Gris'
