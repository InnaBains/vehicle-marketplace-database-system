-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 17, 2026 at 09:46 PM
-- Server version: 11.4.12-MariaDB-cll-lve
-- PHP Version: 8.4.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ysfaekk_Second-Hand Vehicle Marketplace`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`ysfaekk`@`localhost` PROCEDURE `AddOrderAndReturnConfirmation` (IN `inputBuyerID` INT, IN `inputVehicleID` INT)   BEGIN
    DECLARE vehicleMake VARCHAR(50);
    DECLARE vehicleModel VARCHAR(50);
    DECLARE newOrderID INT;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error occurred while placing the order. Please check BuyerID and VehicleID.';
    END;
    IF EXISTS (
        SELECT 1 FROM `Order` WHERE VehicleID = inputVehicleID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This vehicle has already been sold.';
    ELSE
        INSERT INTO `Order` (BuyerID, VehicleID, OrderDate, Status)
        VALUES (inputBuyerID, inputVehicleID, CURDATE(), 'Pending');
        SET newOrderID = LAST_INSERT_ID();
        SELECT Make, Model INTO vehicleMake, vehicleModel
        FROM Vehicle
        WHERE VehicleID = inputVehicleID;
        SELECT newOrderID AS OrderID,
               vehicleMake AS Make,
               vehicleModel AS Model,
               'Pending' AS Status;
    END IF;
END$$

CREATE DEFINER=`ysfaekk`@`localhost` PROCEDURE `FilterVehiclesByConditionAndRange` (IN `cond` VARCHAR(20), IN `minPrice` DECIMAL(10,2), IN `maxPrice` DECIMAL(10,2))   BEGIN
  SELECT 
    Make AS VehicleMake,
    Model AS VehicleModel,
    Year,
    `Condition`,
    CONCAT('£', FORMAT(Price, 2)) AS FormattedPrice
  FROM Vehicle
  WHERE `Condition` = cond
    AND Price BETWEEN minPrice AND maxPrice
  ORDER BY Price ASC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `ActiveOrdersSummary`
-- (See below for the actual view)
--
CREATE TABLE `ActiveOrdersSummary` (
`OrderID` int(11)
,`BuyerName` varchar(101)
,`VehicleMake` varchar(50)
,`VehicleModel` varchar(50)
,`OrderPlaced` varchar(72)
,`Status` varchar(20)
);

-- --------------------------------------------------------

--
-- Table structure for table `Car`
--

CREATE TABLE `Car` (
  `VehicleID` int(11) NOT NULL,
  `NumDoors` int(11) DEFAULT NULL,
  `FuelType` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Car`
--

INSERT INTO `Car` (`VehicleID`, `NumDoors`, `FuelType`) VALUES
(1, 4, 'Petrol'),
(2, 5, 'Diesel'),
(5, 4, 'Hybrid'),
(6, 4, 'Diesel'),
(9, 4, 'Petrol'),
(11, 4, 'Petrol'),
(14, 5, 'Hybrid'),
(15, 4, 'Diesel');

-- --------------------------------------------------------

--
-- Table structure for table `Motorbike`
--

CREATE TABLE `Motorbike` (
  `VehicleID` int(11) NOT NULL,
  `EngineCC` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Motorbike`
--

INSERT INTO `Motorbike` (`VehicleID`, `EngineCC`) VALUES
(3, 321),
(7, 373),
(12, 600);

-- --------------------------------------------------------

--
-- Table structure for table `Order`
--

CREATE TABLE `Order` (
  `OrderID` int(11) NOT NULL,
  `BuyerID` int(11) DEFAULT NULL,
  `VehicleID` int(11) DEFAULT NULL,
  `OrderDate` date DEFAULT curdate(),
  `Status` varchar(20) DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Order`
--

INSERT INTO `Order` (`OrderID`, `BuyerID`, `VehicleID`, `OrderDate`, `Status`) VALUES
(1, 2, 1, '2024-12-01', 'Completed'),
(2, 2, 3, '2025-01-15', 'Pending'),
(3, 3, 5, '2025-02-20', 'Shipped'),
(4, 2, 2, '2025-03-01', 'Completed'),
(5, 3, 4, '2025-04-01', 'Cancelled'),
(6, 6, 6, '2025-04-10', 'Pending'),
(7, 7, 7, '2025-04-12', 'Completed'),
(8, 8, 8, '2025-04-15', 'Cancelled'),
(9, 9, 9, '2025-04-17', 'Pending'),
(10, 10, 10, '2025-04-18', 'Shipped'),
(11, 11, 11, '2025-04-20', 'Completed'),
(12, 12, 12, '2025-04-21', 'Pending'),
(13, 13, 13, '2025-04-22', 'Completed'),
(14, 14, 14, '2025-04-23', 'Pending'),
(15, 15, 15, '2025-04-24', 'Pending'),
(17, 2, 16, '2025-04-11', 'Pending'),
(20, 2, 18, '2025-05-02', 'Pending'),
(21, 2, 17, '2025-05-02', 'Pending');

-- --------------------------------------------------------

--
-- Table structure for table `SearchFilter`
--

CREATE TABLE `SearchFilter` (
  `FilterID` int(11) NOT NULL,
  `UserID` int(11) DEFAULT NULL,
  `FilterName` varchar(50) DEFAULT NULL,
  `Make` varchar(50) DEFAULT NULL,
  `Model` varchar(50) DEFAULT NULL,
  `MaxPrice` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `SearchFilter`
--

INSERT INTO `SearchFilter` (`FilterID`, `UserID`, `FilterName`, `Make`, `Model`, `MaxPrice`) VALUES
(1, 2, 'Affordable Toyotas', 'Toyota', 'Corolla', 9000.00),
(2, 3, 'Bikes under 5K', 'Yamaha', 'YZF-R3', 5000.00),
(3, 2, 'Vans for Business', 'Volkswagen', 'Transporter', 12000.00),
(4, 5, 'Eco Cars', 'Honda', 'Civic', 11000.00),
(5, 5, 'First Car', 'Ford', 'Focus', 10000.00),
(6, 6, 'SUV Search', 'Nissan', 'Qashqai', 10000.00),
(7, 7, 'Dirt Bikes', 'KTM', 'Duke 390', 5500.00),
(8, 8, 'Used Vans', 'Ford', 'Transit', 9000.00),
(9, 9, 'Luxury', 'Audi', 'A3', 15000.00),
(10, 10, 'Budget Van', 'Peugeot', 'Partner', 8000.00),
(11, 11, 'City Car', 'Renault', 'Clio', 7000.00),
(12, 12, 'Performance Bikes', 'Suzuki', 'GSX-R600', 6500.00),
(13, 13, 'Delivery Van', 'Mercedes', 'Sprinter', 17000.00),
(14, 14, 'Reliable Car', 'Hyundai', 'i30', 12000.00),
(15, 15, 'Efficient Family Car', 'Skoda', 'Octavia', 9500.00);

-- --------------------------------------------------------

--
-- Table structure for table `Shipping`
--

CREATE TABLE `Shipping` (
  `ShippingID` int(11) NOT NULL,
  `OrderID` int(11) DEFAULT NULL,
  `ShippingDate` date DEFAULT NULL,
  `DeliveryAddress` varchar(255) DEFAULT NULL,
  `TrackingNumber` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Shipping`
--

INSERT INTO `Shipping` (`ShippingID`, `OrderID`, `ShippingDate`, `DeliveryAddress`, `TrackingNumber`) VALUES
(1, 1, '2024-12-03', '45 Blue Rd, Leeds', 'TRK001UK'),
(2, 3, '2025-02-22', '67 Yellow Ave, York', 'TRK002UK'),
(3, 6, '2025-04-11', '102 Maple Dr, Sheffield', 'TRK003UK'),
(4, 7, '2025-04-13', '23 Elm St, Newcastle', 'TRK004UK'),
(5, 10, '2025-04-19', '55 Willow Ln, Glasgow', 'TRK005UK'),
(6, 11, '2025-04-21', '98 Pine St, Edinburgh', 'TRK006UK'),
(7, 13, '2025-04-23', '12 Peach Dr, Belfast', 'TRK007UK');

-- --------------------------------------------------------

--
-- Table structure for table `User`
--

CREATE TABLE `User` (
  `UserID` int(11) NOT NULL,
  `FirstName` varchar(50) DEFAULT NULL,
  `LastName` varchar(50) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `PhoneNumber` varchar(20) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `UserType` enum('Buyer','Seller','Both') DEFAULT 'Both'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `User`
--

INSERT INTO `User` (`UserID`, `FirstName`, `LastName`, `Email`, `PhoneNumber`, `Address`, `UserType`) VALUES
(1, 'Anna', 'Smith', 'anna@example.com', '+447123456001', '123 Green St, London', 'Seller'),
(2, 'John', 'Doe', 'john@example.com', '+447123456002', '45 Blue Rd, Leeds', 'Buyer'),
(3, 'Mike', 'Taylor', 'mike@example.com', '+447123456003', '67 Yellow Ave, York', 'Both'),
(4, 'Emily', 'Stone', 'emily@example.com', '+447123456004', '89 Red Sq, Bristol', 'Seller'),
(5, 'Olga', 'Ivanova', 'olga@example.com', '+447123456005', '101 Lime Ln, Manchester', 'Both'),
(6, 'George', 'Nash', 'george@example.com', '+447123456006', '102 Maple Dr, Sheffield', 'Buyer'),
(7, 'Laura', 'White', 'laura@example.com', '+447123456007', '23 Elm St, Newcastle', 'Seller'),
(8, 'Tom', 'Williams', 'tom@example.com', '+447123456008', '77 King Rd, Birmingham', 'Both'),
(9, 'Isabella', 'Brown', 'isabella@example.com', '+447123456009', '31 Oak Ave, Liverpool', 'Seller'),
(10, 'Daniel', 'Green', 'daniel@example.com', '+447123456010', '55 Willow Ln, Glasgow', 'Buyer'),
(11, 'Sophia', 'Black', 'sophia@example.com', '+447123456011', '98 Pine St, Edinburgh', 'Both'),
(12, 'Ethan', 'Hill', 'ethan@example.com', '+447123456012', '60 Rose Blvd, Cardiff', 'Buyer'),
(13, 'Ava', 'Gray', 'ava@example.com', '+447123456013', '12 Peach Dr, Belfast', 'Seller'),
(14, 'James', 'Lee', 'james@example.com', '+447123456014', '85 Lake Rd, Nottingham', 'Both'),
(15, 'Mia', 'King', 'mia@example.com', '+447123456015', '40 Park Ln, Oxford', 'Buyer');

-- --------------------------------------------------------

--
-- Stand-in structure for view `UserSearchFilterStats`
-- (See below for the actual view)
--
CREATE TABLE `UserSearchFilterStats` (
`UserID` int(11)
,`Email` varchar(100)
,`TotalSavedFilters` bigint(21)
,`AvgSearchPrice` decimal(11,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `Van`
--

CREATE TABLE `Van` (
  `VehicleID` int(11) NOT NULL,
  `CargoVolume` int(11) DEFAULT NULL,
  `MaxLoad` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Van`
--

INSERT INTO `Van` (`VehicleID`, `CargoVolume`, `MaxLoad`) VALUES
(4, 6000, 1300),
(8, 6500, 1200),
(10, 5800, 1100),
(13, 7500, 1400);

-- --------------------------------------------------------

--
-- Table structure for table `Vehicle`
--

CREATE TABLE `Vehicle` (
  `VehicleID` int(11) NOT NULL,
  `SellerID` int(11) DEFAULT NULL,
  `Make` varchar(50) DEFAULT NULL,
  `Model` varchar(50) DEFAULT NULL,
  `Year` year(4) DEFAULT NULL,
  `Mileage` int(11) DEFAULT NULL,
  `Condition` enum('New','Good','Fair','Poor') DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `VehicleType` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Vehicle`
--

INSERT INTO `Vehicle` (`VehicleID`, `SellerID`, `Make`, `Model`, `Year`, `Mileage`, `Condition`, `Price`, `VehicleType`) VALUES
(1, 1, 'Toyota', 'Corolla', '2015', 60000, 'Good', 8500.00, 'Car'),
(2, 3, 'Ford', 'Focus', '2017', 40000, 'New', 9700.00, 'Car'),
(3, 4, 'Yamaha', 'YZF-R3', '2020', 12000, 'Good', 4300.00, 'Motorbike'),
(4, 5, 'Volkswagen', 'Transporter', '2018', 80000, 'Fair', 11800.00, 'Van'),
(5, 3, 'Honda', 'Civic', '2019', 30000, 'New', 10950.00, 'Car'),
(6, 6, 'Nissan', 'Qashqai', '2016', 70000, 'Good', 9900.00, 'Car'),
(7, 7, 'KTM', 'Duke 390', '2021', 8000, 'New', 5200.00, 'Motorbike'),
(8, 8, 'Ford', 'Transit', '2015', 110000, 'Fair', 8500.00, 'Van'),
(9, 9, 'Audi', 'A3', '2020', 25000, 'Good', 14500.00, 'Car'),
(10, 10, 'Peugeot', 'Partner', '2017', 95000, 'Fair', 7500.00, 'Van'),
(11, 11, 'Renault', 'Clio', '2018', 50000, 'Good', 6800.00, 'Car'),
(12, 12, 'Suzuki', 'GSX-R600', '2022', 5000, 'New', 6200.00, 'Motorbike'),
(13, 13, 'Mercedes', 'Sprinter', '2019', 85000, 'Good', 16500.00, 'Van'),
(14, 14, 'Hyundai', 'i30', '2021', 30000, 'New', 11800.00, 'Car'),
(15, 15, 'Skoda', 'Octavia', '2019', 40000, 'Good', 9200.00, 'Car'),
(16, 1, 'Citroen', 'C4', '2019', 25000, 'Good', 8700.00, 'Car'),
(17, 1, 'Mazda', 'CX-3', '2018', 40000, 'Good', 8700.00, 'Car'),
(18, 2, 'Kia', 'Sportage', '2020', 25000, 'New', 15400.00, 'Car'),
(19, 3, 'Fiat', 'Punto', '2016', 60000, 'Fair', 3500.00, 'Car');

--
-- Triggers `Vehicle`
--
DELIMITER $$
CREATE TRIGGER `BeforeVehicleInsert_CheckPrice` BEFORE INSERT ON `Vehicle` FOR EACH ROW BEGIN
  IF NEW.Price < 1000 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Vehicle price must be at least £1000 for marketplace listing.';
  END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Car`
--
ALTER TABLE `Car`
  ADD PRIMARY KEY (`VehicleID`);

--
-- Indexes for table `Motorbike`
--
ALTER TABLE `Motorbike`
  ADD PRIMARY KEY (`VehicleID`);

--
-- Indexes for table `Order`
--
ALTER TABLE `Order`
  ADD PRIMARY KEY (`OrderID`),
  ADD UNIQUE KEY `VehicleID` (`VehicleID`),
  ADD KEY `BuyerID` (`BuyerID`),
  ADD KEY `idx_orderDate` (`OrderDate`);

--
-- Indexes for table `SearchFilter`
--
ALTER TABLE `SearchFilter`
  ADD PRIMARY KEY (`FilterID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `Shipping`
--
ALTER TABLE `Shipping`
  ADD PRIMARY KEY (`ShippingID`),
  ADD UNIQUE KEY `OrderID` (`OrderID`);

--
-- Indexes for table `User`
--
ALTER TABLE `User`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `Van`
--
ALTER TABLE `Van`
  ADD PRIMARY KEY (`VehicleID`);

--
-- Indexes for table `Vehicle`
--
ALTER TABLE `Vehicle`
  ADD PRIMARY KEY (`VehicleID`),
  ADD KEY `SellerID` (`SellerID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Order`
--
ALTER TABLE `Order`
  MODIFY `OrderID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `SearchFilter`
--
ALTER TABLE `SearchFilter`
  MODIFY `FilterID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `Shipping`
--
ALTER TABLE `Shipping`
  MODIFY `ShippingID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `User`
--
ALTER TABLE `User`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `Vehicle`
--
ALTER TABLE `Vehicle`
  MODIFY `VehicleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

-- --------------------------------------------------------

--
-- Structure for view `ActiveOrdersSummary`
--
DROP TABLE IF EXISTS `ActiveOrdersSummary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`ysfaekk`@`localhost` SQL SECURITY DEFINER VIEW `ActiveOrdersSummary`  AS SELECT `o`.`OrderID` AS `OrderID`, concat(`u`.`FirstName`,' ',`u`.`LastName`) AS `BuyerName`, `v`.`Make` AS `VehicleMake`, `v`.`Model` AS `VehicleModel`, date_format(`o`.`OrderDate`,'%d %M %Y') AS `OrderPlaced`, `o`.`Status` AS `Status` FROM ((`Order` `o` join `User` `u` on(`o`.`BuyerID` = `u`.`UserID`)) join `Vehicle` `v` on(`o`.`VehicleID` = `v`.`VehicleID`)) WHERE `o`.`Status` in ('Pending','Shipped') ;

-- --------------------------------------------------------

--
-- Structure for view `UserSearchFilterStats`
--
DROP TABLE IF EXISTS `UserSearchFilterStats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`ysfaekk`@`localhost` SQL SECURITY DEFINER VIEW `UserSearchFilterStats`  AS SELECT `u`.`UserID` AS `UserID`, `u`.`Email` AS `Email`, count(`sf`.`FilterID`) AS `TotalSavedFilters`, round(avg(`sf`.`MaxPrice`),2) AS `AvgSearchPrice` FROM (`User` `u` left join `SearchFilter` `sf` on(`u`.`UserID` = `sf`.`UserID`)) GROUP BY `u`.`UserID`, `u`.`Email` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Car`
--
ALTER TABLE `Car`
  ADD CONSTRAINT `Car_ibfk_1` FOREIGN KEY (`VehicleID`) REFERENCES `Vehicle` (`VehicleID`);

--
-- Constraints for table `Motorbike`
--
ALTER TABLE `Motorbike`
  ADD CONSTRAINT `Motorbike_ibfk_1` FOREIGN KEY (`VehicleID`) REFERENCES `Vehicle` (`VehicleID`);

--
-- Constraints for table `Order`
--
ALTER TABLE `Order`
  ADD CONSTRAINT `Order_ibfk_1` FOREIGN KEY (`BuyerID`) REFERENCES `User` (`UserID`),
  ADD CONSTRAINT `Order_ibfk_2` FOREIGN KEY (`VehicleID`) REFERENCES `Vehicle` (`VehicleID`);

--
-- Constraints for table `SearchFilter`
--
ALTER TABLE `SearchFilter`
  ADD CONSTRAINT `SearchFilter_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `User` (`UserID`);

--
-- Constraints for table `Shipping`
--
ALTER TABLE `Shipping`
  ADD CONSTRAINT `Shipping_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `Order` (`OrderID`);

--
-- Constraints for table `Van`
--
ALTER TABLE `Van`
  ADD CONSTRAINT `Van_ibfk_1` FOREIGN KEY (`VehicleID`) REFERENCES `Vehicle` (`VehicleID`);

--
-- Constraints for table `Vehicle`
--
ALTER TABLE `Vehicle`
  ADD CONSTRAINT `Vehicle_ibfk_1` FOREIGN KEY (`SellerID`) REFERENCES `User` (`UserID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
