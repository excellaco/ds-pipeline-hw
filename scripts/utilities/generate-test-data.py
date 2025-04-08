# For local development only - not needed in production
import pandas as pd
from faker import Faker

def generate_data():
    fake = Faker()
    data = [{"id": i, "name": fake.name()} for i in range(100)]
    pd.DataFrame(data).to_parquet("test-data.parquet")

if __name__ == "__main__":
    generate_data()