function fish_user_key_bindings
    # Primero cargar los bindings base
    fish_vi_key_bindings
    fzf_key_bindings
    
    # Luego tus bindings personalizados SIN --preset
    # Estos tendrán prioridad sobre los preset
    bind \cf directory-picker
    bind -M insert \cf directory-picker
    bind -M default \cf directory-picker
    
end
