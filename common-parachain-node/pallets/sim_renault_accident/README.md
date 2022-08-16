# SIM Renault accident pallet

Pallet to report an accident at Renault.

<u>Aim:</u> report an accident at Renault by sending a data hash. The raw data should be stored elsewhere.

Actions:
- report_accident(origin: vehicle, vehicle_id, data_hash)

Details:
- data_hash = HASH(vehicle_id, registration_number, datetime_accident, geolocation, speed, brakes, etc.)