// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 7148253319005998380050642785824373164658693774695280759424875402541617629458;
    uint256 constant alphay  = 11531290533363877594519147136883184669516578793159021768945028072375894651602;
    uint256 constant betax1  = 4614398229316951813536843763137653487482549398637042723996795162121685720002;
    uint256 constant betax2  = 7880304368357123333535431189581854446817501335749134981252931840588086236615;
    uint256 constant betay1  = 13313614233769013999244902545568263210318469663813777524483228675792386536078;
    uint256 constant betay2  = 13800712775051465648538981790626391850111188653435676834208023171188871333604;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 10277342760140458042209893399319529291800880308311836786398307573445823152644;
    uint256 constant deltax2 = 18952016128873543961250766887655228690645330362370310151415466688042423319708;
    uint256 constant deltay1 = 1535293113571047555110507122469140774472315631909211382513981656963407462809;
    uint256 constant deltay2 = 20040781467467184980044349692402163570904463673688012888605611720857240196432;

    
    uint256 constant IC0x = 14587704148990952747423402533152925677909702695795590922910905196200545724541;
    uint256 constant IC0y = 19507138724536233769925477404328566117598573766509079048593193005125135425548;
    
    uint256 constant IC1x = 13511855933900068507197911644109642877853274255916224260895509566776978977693;
    uint256 constant IC1y = 9165105540368217393484865137243442630081626248944770380454461360852823773448;
    
    uint256 constant IC2x = 10165848222897931838803865079220156804347883551177517233910216652845888943396;
    uint256 constant IC2y = 16354586533763232103798215531252584867551952994559727177305586694514332648305;
    
    uint256 constant IC3x = 10291047320937446175497430778546504853325742237251444173224753952968001440768;
    uint256 constant IC3y = 2476356225904490089652162366991601464854142604339095828371089433322364788041;
    
    uint256 constant IC4x = 1678927700726265280763840286872532221759265016302655237415097572757207561293;
    uint256 constant IC4y = 14468651595524542240589742544473385528569535717984409277570268632607788350419;
    
    uint256 constant IC5x = 8875030831039111192211390003365330066115021832958996446084718086900881533851;
    uint256 constant IC5y = 7965337902676962255873812595475286237444044731440506473433613236692005942203;
    
    uint256 constant IC6x = 8787714394481040313066012972006506332687159011628270361647593627345395097983;
    uint256 constant IC6y = 3074341921618981138914904725555478242829477447341826277873970356704039202865;
    
    uint256 constant IC7x = 15764429613740789362838671094844404859702491661045299688683941819432219164064;
    uint256 constant IC7y = 14383234026380846454725773875298757392839538549941472317355873460871521661569;
    
    uint256 constant IC8x = 9575683415703664772316295661196805998308786489871320311310666282885688855552;
    uint256 constant IC8y = 5803512582929070285948854636741118583771804901120416079691070317358257934427;
    
    uint256 constant IC9x = 10056306300841926106177867960045258280123620810584536752409896607444320497719;
    uint256 constant IC9y = 364372735410951398973153229525074645079413186993416321228132212874422144578;
    
    uint256 constant IC10x = 10970256961841030953215247731500441742470797066199865686974218465157811560775;
    uint256 constant IC10y = 3457801087566370072949457732121958202419169713882459832065057608882731306133;
    
    uint256 constant IC11x = 17729930692192353981352203994880416354030515017085909984747781180897280121015;
    uint256 constant IC11y = 8286670763166890567451191916300221673099883794072000718090573995298889605730;
    
    uint256 constant IC12x = 8107517400821268456397027177252865183624444431754058075752545138225426669268;
    uint256 constant IC12y = 6117890144829212644992873286699989813464511144431222020503174155912822275505;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[12] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
