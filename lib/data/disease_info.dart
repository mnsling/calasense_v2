// lib/data/disease_info.dart

class DiseaseInfo {
  final String definition;
  final String symptoms;
  final String treatment;

  const DiseaseInfo({
    required this.definition,
    required this.symptoms,
    required this.treatment,
  });
}

const Map<String, DiseaseInfo> diseaseInfoTable = {
  'Leaf Miner': DiseaseInfo(
    definition:
        'Leaf Miners are tiny insects that burrow inside the leaf '
        'tissue, causing visible trails and damage.',
    symptoms:
        'Winding, irregular trails on the leaf surface, yellowing or '
        'pale patches, and distorted growth in severe cases.',
    treatment:
        'Remove affected leaves, use neem oil or approved pesticide, '
        'and monitor regularly for new signs.',
  ),
  'Canker': DiseaseInfo(
    definition:
        'Citrus Canker is a bacterial disease that causes raised, '
        'corky lesions on leaves, stems, and fruit.',
    symptoms:
        'Raised brown lesions with a yellow halo, leaf drop, and '
        'blemished or misshapen fruit.',
    treatment:
        'Prune and destroy infected material, apply copper-based '
        'bactericide, and avoid overhead watering.',
  ),
  'Greening': DiseaseInfo(
    definition:
        'Citrus Greening (Huanglongbing) is a bacterial disease '
        'spread by psyllid insects that damages the tree\'s vascular '
        'system.',
    symptoms:
        'Blotchy yellow mottling on leaves, lopsided and bitter '
        'fruit, and gradual tree decline.',
    treatment:
        'There is no cure; remove and destroy infected trees, and '
        'control psyllid populations with approved insecticide.',
  ),
  'Healthy': DiseaseInfo(
    definition: 'No signs of disease were detected on this leaf.',
    symptoms: 'None. The leaf appears healthy.',
    treatment:
        'No treatment needed. Continue regular care and monitoring.',
  ),
};

const DiseaseInfo _unknownDiseaseInfo = DiseaseInfo(
  definition: 'No information is available for this result.',
  symptoms: 'No information is available for this result.',
  treatment: 'No information is available for this result.',
);

DiseaseInfo getDiseaseInfo(String diseaseName) {
  return diseaseInfoTable[diseaseName] ?? _unknownDiseaseInfo;
}