function encrypt
    if test (count $argv) -lt 2
        echo "Uso: encrypt <archivo_salida.7z> <archivo_o_directorio>"
        echo "Ejemplo: encrypt docs.7z Personal/"
        return 1
    end
    
    7z a -p -mhe=on -mhc=on $argv[1] $argv[2..-1]
end
