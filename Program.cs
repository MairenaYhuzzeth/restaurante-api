using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// ============================================================
// CONEXIÓN A POSTGRESQL / NEON
// ============================================================

var connectionString = builder.Configuration["NEON_CONNECTION_STRING"];

if (string.IsNullOrWhiteSpace(connectionString))
{
    Console.WriteLine("ADVERTENCIA: NEON_CONNECTION_STRING no está configurada.");
}


// ============================================================
// CORS
// ============================================================

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});


// ============================================================
// SERVICIOS DE LA API
// ============================================================

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

var app = builder.Build();


// ============================================================
// CONFIGURACIÓN
// ============================================================

app.UseCors("AllowAll");

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseStaticFiles();


// ============================================================
// PRODUCTOS DE RESPALDO
// ============================================================

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


// ============================================================
// PÁGINA PRINCIPAL
// ============================================================

app.MapGet("/", () =>
{
    return Results.Ok(new
    {
        mensaje = "API del restaurante funcionando correctamente"
    });
});


// ============================================================
// PROBAR CONEXIÓN CON POSTGRESQL
// ============================================================

app.MapGet("/test-db", async () =>
{
    try
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return Results.Problem(
                "La variable NEON_CONNECTION_STRING no está configurada."
            );
        }

        await using var connection =
            new NpgsqlConnection(connectionString);

        await connection.OpenAsync();

        return Results.Ok(new
        {
            mensaje = "Conexión con PostgreSQL funcionando correctamente"
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(ex.Message);
    }
});


// ============================================================
// OBTENER PRODUCTOS DESDE POSTGRESQL
// ============================================================

app.MapGet("/products", async () =>
{
    try
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return Results.Ok(products);
        }

        var result = new List<object>();

        await using var connection =
            new NpgsqlConnection(connectionString);

        await connection.OpenAsync();

        const string sql = """
            SELECT
                p.idproducto,
                p.nombre,
                p.descripcion,
                p.precio,
                p.idcategoria,
                p.imagen,
                p.disponible,
                p.popular
            FROM productos p
            WHERE p.disponible = TRUE
            ORDER BY p.idproducto;
            """;

        await using var command =
            new NpgsqlCommand(sql, connection);

        await using var reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            result.Add(new
            {
                id = $"p{reader.GetInt32(0)}",
                name = reader.GetString(1),

                description =
                    reader.IsDBNull(2)
                        ? ""
                        : reader.GetString(2),

                price = reader.GetDecimal(3),

                categoryId =
                    $"cat{reader.GetInt32(4)}",

                image =
                    reader.IsDBNull(5)
                        ? ""
                        : reader.GetString(5),

                available = reader.GetBoolean(6),
                popular = reader.GetBoolean(7)
            });
        }

        return Results.Ok(result);
    }
    catch (Exception ex)
    {
        Console.WriteLine(
            $"Error al consultar PostgreSQL: {ex.Message}"
        );

        return Results.Ok(products);
    }
});


// ============================================================
// OBTENER CATEGORÍAS DESDE POSTGRESQL
// ============================================================

app.MapGet("/categories", async () =>
{
    try
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return Results.Problem(
                "La variable NEON_CONNECTION_STRING no está configurada."
            );
        }

        var result = new List<object>();

        await using var connection =
            new NpgsqlConnection(connectionString);

        await connection.OpenAsync();

        const string sql = """
            SELECT
                idcategoria,
                nombre,
                descripcion,
                activa
            FROM categorias
            ORDER BY idcategoria;
            """;

        await using var command =
            new NpgsqlCommand(sql, connection);

        await using var reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            result.Add(new
            {
                id = $"cat{reader.GetInt32(0)}",

                name = reader.GetString(1),

                description =
                    reader.IsDBNull(2)
                        ? ""
                        : reader.GetString(2),

                active = reader.GetBoolean(3)
            });
        }

        return Results.Ok(result);
    }
    catch (Exception ex)
    {
        return Results.Problem(ex.Message);
    }
});


// ============================================================
// INICIAR API
// ============================================================

app.Run();