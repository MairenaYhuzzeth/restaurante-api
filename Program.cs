var builder = WebApplication.CreateBuilder(args);

// CORS para permitir peticiones desde Flutter
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

var app = builder.Build();

app.UseCors("AllowAll");

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseStaticFiles();

// Página principal
app.MapGet("/", () =>
{
    return Results.Ok(new
    {
        mensaje = "API del restaurante funcionando correctamente"
    });
});

// Lista de productos
var products = new[]
{
    new
    {
        id = "p1",
        name = "Hamburguesa Clásica",
        description = "Carne de res, queso cheddar, lechuga, tomate y salsa especial.",
        price = 7.99,
        categoryId = "cat1",
        image = "https://images.unsplash.com/photo-1568901346375-23c9450c58cd",
        available = true,
        popular = true
    },
    new
    {
        id = "p2",
        name = "Hamburguesa BBQ",
        description = "Carne de res, queso, tocino crujiente y salsa BBQ.",
        price = 9.99,
        categoryId = "cat1",
        image = "https://images.unsplash.com/photo-1553979459-d2229ba7433b",
        available = true,
        popular = true
    },
    new
    {
        id = "p3",
        name = "Pizza Pepperoni",
        description = "Salsa de tomate, mozzarella y abundante pepperoni.",
        price = 12.99,
        categoryId = "cat2",
        image = "https://images.unsplash.com/photo-1628840042765-356cda07504e",
        available = true,
        popular = true
    },
    new
    {
        id = "p4",
        name = "Pizza Vegetariana",
        description = "Mozzarella, champiñones, tomate, cebolla, chile dulce y aceitunas.",
        price = 13.50,
        categoryId = "cat2",
        image = "https://images.unsplash.com/photo-1574071318508-1cdbab80d002",
        available = true,
        popular = false
    },
    new
    {
        id = "p5",
        name = "Pollo Crispy",
        description = "Pechuga de pollo empanizada con papas fritas.",
        price = 8.99,
        categoryId = "cat3",
        image = "https://images.unsplash.com/photo-1562967916-eb82221dfb92",
        available = true,
        popular = true
    },
    new
    {
        id = "p6",
        name = "Ensalada César",
        description = "Lechuga fresca, pollo, parmesano y aderezo César.",
        price = 6.99,
        categoryId = "cat4",
        image = "https://images.unsplash.com/photo-1550304943-4f24f54ddde9",
        available = true,
        popular = false
    },
    new
    {
        id = "p7",
        name = "Gaseosa",
        description = "Bebida gaseosa fría de 500 ml.",
        price = 1.50,
        categoryId = "cat5",
        image = "https://images.unsplash.com/photo-1629203851122-3726ecdf080e",
        available = true,
        popular = false
    },
    new
    {
        id = "p8",
        name = "Limonada Natural",
        description = "Limonada natural preparada al momento.",
        price = 2.25,
        categoryId = "cat5",
        image = "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd",
        available = true,
        popular = false
    },
    new
    {
        id = "p9",
        name = "Cheesecake",
        description = "Cheesecake cremoso con salsa de frutos rojos.",
        price = 4.99,
        categoryId = "cat6",
        image = "https://images.unsplash.com/photo-1565958011703-44f9829ba187",
        available = true,
        popular = false
    }
};

// GET /products
app.MapGet("/products", () =>
{
    return Results.Ok(products);
});

app.Run();