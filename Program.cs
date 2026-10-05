var builder = WebApplication.CreateBuilder(args);

// 1. Agregar política de CORS para permitir peticiones desde cualquier origen (Flutter Web)
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

// 2. Activar CORS (¡Importante que vaya antes de app.Run() y de tus endpoints!)
app.UseCors("AllowAll");

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseStaticFiles();

// ... (el resto de tu código de platillos sigue igual)