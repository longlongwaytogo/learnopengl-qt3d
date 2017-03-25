import QtQuick 2.7
import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Extras 2.0

import VirtualKey 1.0

import "Components"

Scene2 {
	id: scene
	children: VirtualKeys {
		target: scene
		enableGameButtons: false
		color: "transparent"
		centerItem: RowKeys {
			keys: [
				{text:"Space", key:Qt.Key_Space},
			]
		}
	}

	Entity {
		id: root

		RenderInputSettings0 {
			id: renderInputSettings

			mouseSensitivity: 0.5 / Units.dp
		}

		KeyboardDevice {
			id: keyboardDevice
		}

		KeyboardHandler {
			id: keyboardHandler
			sourceDevice: keyboardDevice
			focus: true

			onSpacePressed: {
				root.useQtMaterial = !root.useQtMaterial;
				console.log("useQtMaterial:", root.useQtMaterial);
			}
		}

		property bool useQtMaterial: false

		property vector3d viewPos: renderInputSettings.camera.position
		property color lightColor: "white"
		property var material: QtObject {
			property string diffuse: Resources.texture("container2.png")
			property vector3d specular: "0.5, 0.5, 0.5"
			property real shininess: 64.0
		}

		QtObject {
			id: light

			property vector3d position: "1.2, 1.0, 2.0"

			property vector3d ambient: ".2, .2, .2"
			property vector3d diffuse: ".5, .5, .5"
			property vector3d specular: "1., 1., 1."
		}

		CuboidMesh {
			id: mesh
		}

		Entity {
			id: object

			Transform {
				id: objectTransform
			}

			Material {
				id: ourMaterial
				effect: Effect {
					techniques: Technique {
						renderPasses: RenderPass {
							shaderProgram: ShaderProgram0 {
								vertName: "lighting_maps"
								fragName: "lighting_maps_diffuse"
							}
							parameters: [
								Parameter {
									name: "viewPos"
									value: root.viewPos
								},
								Parameter {
									name: "material.diffuse"
									value: Texture2D {
										TextureImage {
											source: root.material.diffuse
										}
									}
								},
								Parameter {
									name: "material.specular"
									value: root.material.specular
								},
								Parameter {
									name: "material.shininess"
									value: root.material.shininess
								},
								Parameter {
									name: "light.position"
									value: light.position
								},
								Parameter {
									name: "light.ambient"
									value: light.ambient
								},
								Parameter {
									name: "light.diffuse"
									value: light.diffuse
								},
								Parameter {
									name: "light.specular"
									value: light.specular
								}
							]
						}
					}
				}
			}

			DiffuseMapMaterial {
				/*
					Phong material with diffuse map in Qt3D.Extras,
					Qt PointLight is required to work with
					The model is different with learnopengl.com
					Src: Src/qt3d/src/quick3d/imports/extras/defaults/qml/DiffuseMapMaterial.qml
				*/

				id: qtMaterial
				ambient: Qt.rgba(light.ambient.x, light.ambient.y, light.ambient.z, 1.) // ...
				diffuse: root.material.diffuse
				specular: Qt.rgba(root.material.specular.x, root.material.specular.y,
					root.material.specular.z, 1.)
				shininess: root.material.shininess
			}

			components: [mesh, objectTransform, root.useQtMaterial?qtMaterial:ourMaterial]
		}

		Entity {
			id: lamp

			PointLight {
				id: qtLamp
				color: root.lightColor
				intensity: 1
			}

			Transform {
				id: lampTransform
				translation: light.position
				scale: .2
			}

			Material {
				id: lampMaterial
				effect: Effect {
					techniques: Technique {
						renderPasses: RenderPass {
							shaderProgram: ShaderProgram0 {
								vertName: "basic_lighting"
								fragName: "shaders-uniform"
							}
							parameters: [
								Parameter {
									name: "ourColor"
									value: root.lightColor
								}
							]
						}
					}
				}
			}

			components: [mesh, qtLamp, lampTransform, lampMaterial]
		}
	}
}