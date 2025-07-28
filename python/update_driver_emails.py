import psycopg2
from psycopg2 import Error

# Database connection parameters
DB_NAME = "nganya1"
DB_USER = "olal"
DB_PASSWORD = "$@m01011001"  # You'll need to provide the correct password
DB_HOST = "localhost"
DB_PORT = "5432"

def update_driver_emails():
    try:
        # Connect to PostgreSQL database
        connection = psycopg2.connect(
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        
        cursor = connection.cursor()
        
        # Get all drivers
        cursor.execute("SELECT id, username FROM users WHERE role = 'DRIVER'")
        drivers = cursor.fetchall()
        
        print(f"Found {len(drivers)} drivers")
        
        # Update each driver's email to a unique one
        for driver in drivers:
            driver_id, username = driver
            new_email = f"{username}@nganya.com"
            
            # Update the email
            update_query = "UPDATE users SET email = %s WHERE id = %s"
            cursor.execute(update_query, (new_email, driver_id))
            print(f"Updated driver {username} (ID: {driver_id}) with email: {new_email}")
        
        # Commit the changes
        connection.commit()
        print("\nAll driver emails have been updated successfully!")
        
    except (Exception, Error) as error:
        print("Error while connecting to PostgreSQL:", error)
    finally:
        if connection:
            cursor.close()
            connection.close()
            print("\nPostgreSQL connection is closed")

if __name__ == "__main__":
    update_driver_emails() 