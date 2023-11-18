use dep::std::ec::tecurve::affine::Curve as AffineCurve;
use dep::std::ec::tecurve::affine::Point as AffinePoint;
use dep::std::collections::vec::Vec;
use dep::std;
use dep::std::ec;

struct Nullifier {
    publicKey: AffinePoint,
    nullifier: AffinePoint,
    s: Field,
    c: Field,
}

impl Nullifier {
    fn verify(self) -> bool {
        true
    }
}

fn getCurve() -> AffineCurve {
   AffineCurve::new(168700, 168696, AffinePoint::new(995203441582195749578291179787384436505546430278305826713579947235728471134,5472060717959818805561601436314318772137091100104008585924551046643952123905))
}

fn run() {
    let c = getCurve();
    c::contains()
}

fn main(x: Field, y: pub Field) {
    run();
}

#[test]
fn test_main() {
    main(1, 2);

    // Uncomment to make test fail
    // main(1, 1);
}
