from sqlalchemy import create_engine, Table, Column, Integer, String, MetaData
from sqlalchemy.sql import select
import logging

# Configuration des logs pour voir le SQL généré (optionnel)
logging.basicConfig() 
log = logging.getLogger('sqlalchemy.engine')
log.setLevel(logging.INFO)

metadata = MetaData()
users_table = Table(
    "users", metadata,
    Column("id", Integer, primary_key=True),
    Column("username", String(50)),
    Column("email", String(120))
)

# Création d'un moteur local pour test (remplacer par vos paramètres)
engine = create_engine("sqlite:///:memory:", echo=True)
metadata.create_all(engine)

def execute_query():
    # Maîtriser sqlalchemy core permet de construire des requêtes propres
    stmt = select(users_table).where(users_table.c.username == "test_user")
    
    with engine.connect()
        result = conn.execute(stmt)
        for row in result:
            print(f"User found: {row[1]} ({row[2]})")

if __name__ == "__main__":
    # Pour exécuter ce script, assurez-vous d'avoir SQLAlchemy installé.
    execute_query()