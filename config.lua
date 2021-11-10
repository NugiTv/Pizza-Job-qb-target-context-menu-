------------
-- CONFIG --
------------
Config = {}

Config.Positions = {

    Vehicle = vector3(-373.58, 1889.29, 9.96), --- Job Location

    Spawn = vector4(-380.26, 1900.92, 9.83, 359.4) --- Pizza Car Spawn Location
}

Config.DeliveryLocations = {
    vector4(136.82, 1473.89, 13.9, 180.0), --- Pizza Locations For Ped And Job
                                 -- ^^^^ peds heading
    vector4(-399.38, 822.92, 8.9, 180.0),

    vector4(-790.16, 1896.41, 15.9, 180.0), vector4(40.41, 76.46, 4.5, 180.0),

    vector4(373.33, 1816.01, 10.37, 180.0),

    vector4(-902.37, 191.56, 69.44, 180.0),

    vector4(-1116.81, 304.54, 66.52, 180.0)
}

Config.PedList = {
    "a_m_m_tourist_01", "a_m_m_socenlat_01", "a_m_y_downtown_01",

    "a_m_y_salton_01"
}

Config.Car = 'panto' -- Pizza Car Model

Config.CoreName = 'yamiecore' -- Core Name -- Your core has to have get core by export


---------------------EVENT TO TAKE PIZZA OUT OF THE CAR & DELIVER!!!
--RegisterNetEvent('pizzajob:takepizza', function()

 --------------------EVENT TO TAKE PIZZA JOB!!!
--RegisterNetEvent('takepizzajob', function()

--------------event to open job menu on panto
--RegisterNetEvent('caroptionmenu', function()