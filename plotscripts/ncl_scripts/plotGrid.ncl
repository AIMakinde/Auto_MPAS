;=======================================================================
; This script plots MPAS grid with conditional masking for less-dense regions.
; Only edges with an approximate length greater than the mask_threshold (km)
; are drawn. Adjust mask_threshold below to control which grid lines are shown.
;
; USAGE: ===================
;      ncl plotGrid.ncl
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  ;-------------------------
  ; User settings
  ;-------------------------
  ; Threshold in km: only edges longer than this value will be drawn.
  mask_threshold = 20.0
  
  ; Conversion factor: radians to degrees.
  r2d = 57.2957795             
  ; Degrees to radians conversion factor.
  d2r = 0.01745329252

  ;-------------------------
  ; Open workstation and define colormap
  ;-------------------------
  wks = gsn_open_wks("png", "Fig3")
  colors = (/"white", "black", "lightskyblue1", "lightskyblue1", "bisque"/)
  gsn_define_colormap(wks, colors)

  ;-------------------------
  ; Read grid file and extract variables
  ;-------------------------
  gridfile = "x20.835586.grid.nc"
  f        = addfile(gridfile, "r")

  xVertex         = f->xVertex(:)
  yVertex         = f->yVertex(:)
  zVertex         = f->zVertex(:)
  verticesOnCell  = f->verticesOnCell(:,:)
  verticesOnEdge  = f->verticesOnEdge(:,:)
  x               = f->lonCell(:) * r2d
  y               = f->latCell(:)  * r2d
  lonCell         = f->lonCell(:)  * r2d
  latCell         = f->latCell(:)  * r2d
  lonVertex       = f->lonVertex(:) * r2d
  latVertex       = f->latVertex(:) * r2d
  lonEdge         = f->lonEdge(:)   * r2d
  latEdge         = f->latEdge(:)   * r2d

  ;-------------------------
  ; Set up map resources
  ;-------------------------
  res                   = True
  res@gsnMaximize       = True
  res@cnLevelSpacingF   = 8.0
  res@mpProjection      = "Orthographic"
  res@mpDataBaseVersion = "MediumRes"
  res@mpCenterLatF      = 0.
  res@mpCenterLonF      = 0.
; res@mpCenterRotF      = 0.
  res@mpGridAndLimbOn   = False
  res@mpOutlineOn       = True
  res@mpFillOn          = True
  res@mpPerimOn         = False
  res@gsnFrame          = False
  res@mpOceanFillColor  = 3
  res@mpInlandWaterFillColor = 3
  res@mpLandFillColor   = 4

  map = gsn_csm_map(wks, res)

  ;-------------------------
  ; Set polyline resource for grid lines
  ;-------------------------
  lres = True
  lres@gsLineThicknessF = 1.50

  ;-------------------------
  ; Prepare to draw grid edges
  ;-------------------------
  esizes = dimsizes(latEdge)
  ecx = new((/esizes(0), 2/), double)
  ecy = new((/esizes(0), 2/), double)

  do j = 0, esizes(0)-1
     ecx(j,0) = lonVertex( verticesOnEdge(j,0)-1 )
     ecy(j,0) = latVertex( verticesOnEdge(j,0)-1 )
     ecx(j,1) = lonVertex( verticesOnEdge(j,1)-1 )
     ecy(j,1) = latVertex( verticesOnEdge(j,1)-1 )
  end do

  ; Adjust longitudes if the difference is greater than 180 degrees (wrap-around correction)
  do j = 0, esizes(0)-1
     if (abs(ecx(j,0) - ecx(j,1)) .gt. 180.0) then
        if (ecx(j,0) .gt. ecx(j,1)) then
           ecx(j,0) = ecx(j,0) - 360.0
        else
           ecx(j,1) = ecx(j,1) - 360.0
        end if
     end if
  end do

  ;-------------------------
  ; Draw grid edges only if the edge length is above the threshold
  ;-------------------------
  do j = 0, esizes(0)-1
     ; Compute the approximate distance (in km) between the two vertices of the edge.
     ; dlat (in degrees) ~ 111 km per degree; dlon depends on latitude.
     dlat = abs(ecy(j,1) - ecy(j,0))
     dlon = abs(ecx(j,1) - ecx(j,0))
     avgLat = (ecy(j,0) + ecy(j,1)) / 2.0
     
     ; Approximate conversion: 1 degree latitude ~ 111 km; 1 degree longitude ~ 111*cos(lat) km.
     dist = sqrt((dlat * 111.0)^2 + (dlon * 111.0 * cos(avgLat*d2r))^2)
     
     if (dist .ge. mask_threshold) then
        gsn_polyline(wks, map, ecx(j,:), ecy(j,:), lres)
     end if
  end do

  frame(wks)

end
