package net.systemeD.potlatch2 {

	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.containers.Panel;
	import net.systemeD.halcyon.connection.*;
    import net.systemeD.potlatch2.controller.*;
    import net.systemeD.potlatch2.tools.*;

	/*
		Floating toolbox palette

		Still to do:
		** Should have close and minimise boxes, and be able to be activated from the top bar
		** Should be automatically positioned at bottom-right of canvas on init
		** Remove annoying Illustrator cruft from SVG icons!
		** Tooltips

	*/

	public class Toolbox extends TitleWindow {
		
		private var entity:Entity;
		private var controller:EditController;

		public function Toolbox(){
			super();
		}
		
		public function init(controller:EditController):void {
			this.controller=controller;
		}

		override protected function createChildren():void {
			super.createChildren();
			super.titleBar.addEventListener(MouseEvent.MOUSE_DOWN,handleDown);
			super.titleBar.addEventListener(MouseEvent.MOUSE_UP,handleUp);
		}

		public function setEntity(entity:Entity):void {
			this.entity=entity;
			dispatchEvent(new Event("updateSkin"));
			dispatchEvent(new Event("updateAlpha"));
		}

		private function handleDown(e:Event):void {
			this.startDrag();
		}

		private function handleUp(e:Event):void {
			this.stopDrag();
		}
		
		// --------------------------------------------------------------------------------
		// Enable/disable toolbox buttons
		// (ideally we'd use CSS to set alpha in disabled state, but Flex's CSS
		//  capabilities aren't up to it)
		
        [Bindable(event="updateSkin")]
		public function canDo(op:String):Boolean {
			switch (op) {
				case 'delete':				return (entity is Way || entity is Node);
				case 'reverseDirection':	return (entity is Way);
				case 'quadrilateralise':	return (entity is Way && Way(entity).isArea());
				case 'straighten':			return (entity is Way && !Way(entity).isArea());
				case 'circularise':			return (entity is Way && Way(entity).isArea());
				case 'split':				return (entity is Node && controller.state is SelectedWayNode);
				case 'parallelise':			return (entity is Way);
			}
			return false;
		}

        [Bindable(event="updateAlpha")]
		public function getAlpha(op:String):Number {
			if (canDo(op)) { return 1; }
			return 0.5;
		}
        

		// --------------------------------------------------------------------------------
		// Individual toolbox actions

		public function doDelete():void {
			if (entity is Node) { controller.connection.unregisterPOI(Node(entity)); }
			entity.remove(MainUndoStack.getGlobalStack().addAction);

			if (controller.state is SelectedWayNode) {
				controller.setState(new SelectedWay(SelectedWayNode(controller.state).selectedWay));
			} else {
				controller.setState(new NoSelection());
			}
		}

        public function doReverseDirection():void {
            if (entity is Way) { 
                Way(entity).reverseNodes(MainUndoStack.getGlobalStack().addAction);
            }
        }

		public function doQuadrilateralise():void {
			if (entity is Way) {
				Quadrilateralise.quadrilateralise(Way(entity));
			}
		}

		public function doStraighten():void {
			if (entity is Way) {
				Straighten.straighten(Way(entity),controller.map);
			}
		}

		public function doCircularise():void {
			if (entity is Way) {
				Circularise.circularise(Way(entity),controller.map);
			}
		}

		public function doSplit():void {
			if (entity is Node && controller.state is SelectedWayNode) {
				controller.setState(SelectedWayNode(controller.state).splitWay());
			}
		}
		
		public function doParallelise():void {
			if (entity is Way) {
				controller.setState(new SelectedParallelWay(Way(entity)));
			}
		}

	}
}
