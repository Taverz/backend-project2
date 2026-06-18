from fastapi import FastAPI 
from pydantic import BaseModel

app = FastAPI()

@app.get("/")
def read_root():
    return {"message":"Hi!"}

# uvicorn main:app --reload

@app.get("/items/{tem_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "query": q}


class Item(BaseModel):
    name:str 
    price: float
    is_offer: bool = None 

@app.post("/items/")
def create_item(item: Item):
    return {"item_name":item.name, "price_with_tax":item.price * 1.2}


@app.get("/search/")
def search_items(
    q: str = Query(..., min_length=3, max_length=50),
    page: int = Query(1, ge=1),
    size: int = Query(10, le=100)
): return {"query": q, "page": page, "size": size}

