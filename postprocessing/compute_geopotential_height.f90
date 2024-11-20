 !***********************************************************************
   !
   !  routine compute_geopotential_height
   !
   !> \brief   Convert geometric height to geopotential height
   !>          Adopted from convert_gpsro_bufr.f90 in DART/observations/gps/. 
   !> \author  Soyoung Ha
   !> \date    17 Feb 2017
   !
   !> \details
   !>  Given latitude (in degree), convert geometric height (in meter)
   !>  into geopotential height (in meter).
   !>  
   !>  Input:   
   !>  ncol -- nCells
   !>  nlev -- nIsobaricLevels
   !>  lat  -- latitude [radian]   
   !>  H    -- geometric height [m]
   !>  
   !>  Output:   
   !>  GPH  -- geopotential height [m]
   !>  
   !----------------------------------------------------------------------- 
    subroutine compute_geopotential_height(ncol, nlev, lat, H, GPH)

        implicit none
 
     !  Input and Output arguments:
        integer,          intent(in):: ncol, nlev
        real(kind=RKIND), intent(in),  dimension(ncol)       :: lat
        real(kind=RKIND), intent(in),  dimension(nlev,ncol)  :: H
        real(kind=RKIND), intent(out), dimension(nlev,ncol)  :: GPH
 
     !  Local variables
        integer :: k, iCell
        real(kind=RKIND), dimension(ncol) :: sin2, termr, termg
        real(kind=RKIND) :: semi_major_axis, semi_minor_axis, grav_polar, grav_equator
        real(kind=RKIND) :: earth_omega, grav_constant, flattening, somigliana
        real(kind=RKIND) :: grav_ratio, grav, eccentricity
 
     !  Parameters below from WGS-84 model software inside GPS receivers.
        parameter(semi_major_axis = 6378.1370e3_RKIND)    ! (m)
        parameter(semi_minor_axis = 6356.7523142e3_RKIND) ! (m)
        parameter(grav_polar = 9.8321849378_RKIND)        ! (m/s2)
        parameter(grav_equator = 9.7803253359_RKIND)      ! (m/s2)
 
        parameter(earth_omega = 7.292115e-5_RKIND)        ! (rad/s)  
        parameter(grav = 9.80665_RKIND)                 ! (m/s2) WMO std g at 45 deg lat
 
        parameter(grav_constant = 3.986004418e14_RKIND)   ! (m3/s2)
        parameter(eccentricity = 0.081819_RKIND)        ! unitless
 
     !  Derived geophysical constants
        parameter(flattening = (semi_major_axis-semi_minor_axis) / semi_major_axis)
 
        parameter(somigliana = (semi_minor_axis/semi_major_axis)*(grav_polar/grav_equator)-1.0_RKIND)
 
        parameter(grav_ratio = (earth_omega*earth_omega * &
                                semi_major_axis*semi_major_axis * semi_minor_axis)/grav_constant)
 
        sin2(:)  = sin(lat(:))**2
        termg(:) = grav_equator * ( (1.0_RKIND+somigliana*sin2(:)) / &
                       sqrt(1.0_RKIND - eccentricity**2 * sin2(:)) )
        termr(:) = semi_major_axis / (1.0_RKIND + flattening + grav_ratio - 2.0_RKIND*flattening*sin2(:))
 
        do iCell = 1, ncol
           do k = 1, nlev
              GPH(k,iCell) = (termg(iCell)/grav)*((termr(iCell)*H(k,iCell))/(termr(iCell)+H(k,iCell)))
           end do
        end do
 
     end subroutine compute_geopotential_height