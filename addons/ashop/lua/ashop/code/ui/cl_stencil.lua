// Flux shenanigans
local render = render

function ashop.StartStencil()
    render.ClearStencil()
    render.SetStencilWriteMask( 0xFF )
    render.SetStencilTestMask( 0xFF )
    
    render.SetStencilPassOperation( STENCIL_REPLACE )
    render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_KEEP )
    render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.SetStencilReferenceValue( 1 )
    render.SetStencilEnable( true )
end

function ashop.ReplaceStencil(id)
    -- Purpose : if the pixel is 0 ( so everything outside the draw before )
    -- then, draw our thing on it
    render.SetStencilCompareFunction( STENCIL_EQUAL )

    -- what we do if it's true
    render.SetStencilPassOperation( STENCIL_REPLACE )
    render.SetStencilReferenceValue( id or 0 )
end

function ashop.EndStencil()
    render.SetStencilEnable( false )
end