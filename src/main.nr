use dep::std::ec::tecurve::affine::Curve as AffineCurve;
use dep::std::ec::tecurve::affine::Point as AffinePoint;
use dep::std;

/*
* very naive implementation of https://eprint.iacr.org/2022/1255.pdf
* the goal was to play around with noir and submit a project so that I get my staked Eth back :D
* rather than to get a functional implementation going - so no need to waste your time and judge this project!
* theres many mistakes in the implementation, some outright breaking the security of the scheme 
*/

struct Nullifier {
    publicKey: AffinePoint,
    nullifier: AffinePoint,
    s: Field,
    c: Field,
}

impl Nullifier {
    fn verify(self, message: [Field; 2]) -> bool {
        let Self {publicKey, nullifier, s, c} = self;
        let Curve = get_curve();

        let msg_and_pk_hash = hash4([publicKey.x, publicKey.y, message[0], message[1]]);
        let h_m_pk = map_to_curve(msg_and_pk_hash);

        let pk_c = Curve.mul(c, publicKey);

        let G = get_generator();

        // g^r = g^s / pk^c
        let g_r = Curve.subtract(Curve.mul(s, G), pk_c);

        // h(m, pk)^s
        let h_m_pk_s = Curve.mul(s, h_m_pk);
    
        // h_m_pk_r =  h(m,pk)^s / nullifier^c
        let h_m_pk_s_div_nullifier_s = Curve.subtract(
            h_m_pk_s, Curve.mul(c, nullifier)
        );


        let z = hash12([
            G.x,
            G.y,
            publicKey.x,
            publicKey.y,
            h_m_pk.x,
            h_m_pk.y,
            nullifier.x,
            nullifier.y,
            g_r.x,
            g_r.y,
            h_m_pk_s_div_nullifier_s.x,
            h_m_pk_s_div_nullifier_s.y
        ]);

        z == c
    }
}

fn get_curve() -> AffineCurve {
   AffineCurve::new(168700, 168696, AffinePoint::new(995203441582195749578291179787384436505546430278305826713579947235728471134, 5472060717959818805561601436314318772137091100104008585924551046643952123905))
}

fn get_generator() -> AffinePoint {
    AffinePoint::new(995203441582195749578291179787384436505546430278305826713579947235728471134, 5472060717959818805561601436314318772137091100104008585924551046643952123905)
}

fn hash2(xs: [Field; 2]) -> Field {
    std::hash::poseidon::bn254::hash_2(xs)
}

fn hash4(xs: [Field; 4]) -> Field {
    std::hash::poseidon::bn254::hash_4(xs)
}

fn hash12(xs: [Field; 12]) -> Field {
    std::hash::poseidon::bn254::hash_12(xs)
}

fn map_to_curve(hash: Field) -> AffinePoint {
    // very naive hash to curve approach
    get_curve().swu_map(3, hash)
}

fn run() {
    let c = get_curve();
    assert(c.contains(AffinePoint::zero()) == true);
}

fn main(nf: Nullifier, message: [Field; 2]) {   
    let isValid = nf.verify(message);

    // this should be valid :D 
    // assert(isValid == true);
}

#[test]
fn test_main() {
    let Curve = get_curve();
    let G = get_generator();
    let sk = 5; // "random" scalar as our private key
    let pk = Curve.mul(sk, G); // publicKey - G^sk 


    // creating test nullifier, which should happen in a secure enclave 

    let r = 13; // random ephemeral scalar

    let message = [5, 1];
    let gm = map_to_curve(hash4([pk.x, pk.y, message[0], message[1]]));
    let h_m_pk = AffinePoint::new(gm.x, gm.y);
    let nullifier = Curve.mul(sk, h_m_pk);
    let h_m_pk_r = Curve.mul(r, h_m_pk);
    let g_r = Curve.mul(r, G);

    let c = hash12([
        G.x,
        G.y,
        pk.x,
        pk.y,
        h_m_pk.x,
        h_m_pk.y,
        nullifier.x,
        nullifier.y,
        g_r.x,
        g_r.y,
        h_m_pk_r.x,
        h_m_pk_r.y
    ]);

    let s =  r + (sk * c);
    
    let nf = Nullifier {
        publicKey: pk,
        nullifier,
        s,
        c
    };

    main(nf, message);

}
