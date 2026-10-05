var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseStaticFiles();

// 1. Base de datos simulada con los precios marcados como decimales (con la 'm')
var platillos = new List<Platillo>
{
    new Platillo(1, "Hamburguesa Especial", "Comidas", 12.50m, "Doble carne, queso cheddar y tocino crujiente."),
    new Platillo(2, "Pizza Margarita", "Comidas", 15.00m, "Salsa de tomate artesanal, mozzarella fresca y albahaca."),
    new Platillo(3, "Limonada con Hierbabuena", "Bebidas", 3.50m, "Refrescante limonada natural con toque de menta."),
    new Platillo(4, "Cheesecake de Frutos Rojos", "Postres", 6.00m, "Suave pastel de queso con mermelada casera.")
};

// 2. ENDPOINT GET: Obtener todo el menú
app.MapGet("/api/menu", () => Results.Ok(platillos))
   .WithName("GetMenu");

// 3. ENDPOINT POST: Agregar un nuevo platillo (Administrador)
app.MapPost("/api/menu", (Platillo nuevoPlatillo) =>
{
    var idGenerado = platillos.Count > 0 ? platillos.Max(p => p.Id) + 1 : 1;
    var platilloConId = nuevoPlatillo with { Id = idGenerado };
    
    platillos.Add(platilloConId);
    return Results.Created($"/api/menu/{idGenerado}", platilloConId);
})
.WithName("AddPlatillo");

// 4. ENDPOINT DELETE: Borrar un platillo por ID (Administrador)
app.MapDelete("/api/menu/{id}", (int id) =>
{
    var platillo = platillos.FirstOrDefault(p => p.Id == id);
    if (platillo is null) return Results.NotFound();

    platillos.Remove(platillo);
    return Results.NoContent();
})
.WithName("DeletePlatillo");

app.MapFallbackToFile("index.html");

app.Run();

public record Platillo(int Id, string Nombre, string Categoria, decimal Precio, string Descripcion);